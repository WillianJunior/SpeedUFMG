# Working on the SONIC cluster (SPEED / DCC-UFMG)

Rules for any agent or person running work on this cluster, independent of
project. Reference: <https://github.com/WillianJunior/SpeedUFMG> and its wiki.
Project-specific facts belong in each repo's own notes, not here.

## 1. Never run work on the login node

`phocus4` is the login node — the front door shared by everyone in the lab.
The house rule from the cluster docs is blunt: do not run jobs on phocus4.
It is for fetching code, editing, compiling and submitting jobs. Nothing else.

Not on the login node:

- training, evaluation, benchmarks, simulations, anything numeric;
- full-dataset scans, bulk copies, archive extraction, dataset rebuilds;
- heavy framework imports — the login node is not the same CPU as the compute
  nodes and a bare import can die with `Illegal instruction`;
- **anything in the background** — see the next section.

Allowed on the login node: reading and editing files, `git`, small text
processing, `sinfo` / `squeue` / `sacct` / `scontrol`, `sbatch`, compiling.

`htop` shows who is consuming the login node if it feels slow.

## 2. No background processes, no thread fan-out

**Do not leave anything running between commands on the login node.** No
watcher loops (`until squeue …; do sleep; done`), no `tail -f`, no trailing
`&`, no polling retry loop, no long-lived server. A loop that "only sleeps"
still holds memory, wakes the scheduler and hits the shared filesystem for as
long as it lives, on a machine other people are typing into.

To check on a job, run `squeue` or `sacct` **once**, when the answer is
actually needed, and read the job's log file directly. The job runs on a
compute node and needs nothing from the login node to progress.

**Do not spawn many concurrent threads, workers or subprocesses** — on the
login node at all, and inside a job beyond what was allocated. A job that asks
for 8 CPUs and starts 64 threads does not run faster; it thrashes and steals
from co-scheduled jobs. Concretely:

- pin thread pools to the allocation, in the job script, before anything runs:

  ```bash
  export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
  export MKL_NUM_THREADS=$OMP_NUM_THREADS
  export OPENBLAS_NUM_THREADS=$OMP_NUM_THREADS
  export NUMEXPR_NUM_THREADS=$OMP_NUM_THREADS
  ```

  Numerical libraries default to "one thread per visible core", and they see
  the whole machine, not the allocation.
- cap data-loader and pool workers explicitly (`num_workers`, `n_jobs`,
  `ProcessPoolExecutor(max_workers=…)`) at the allocated CPU count, never at
  `os.cpu_count()`.
- `CPUTot` counts hyperthreads: 32 CPUs on a gorgona is 16 physical cores, 64
  on a medusa is 32. For compute-bound code the useful ceiling is the physical
  core count, not the SLURM number.
- prefer one array job of N tasks, which the scheduler paces, over one script
  that forks N children itself.
- more parallelism than the storage can feed is negative: if workers sit
  waiting on the shared filesystem, adding workers slows everyone down.

## 3. The way in is an interactive job

Anything exploratory goes to a compute node through the debug partition:

```bash
srun --partition=gorgonas_dev --time=01:30:00 --pty bash        # interactive shell
srun --partition=gorgonas_dev --time=00:30:00 python probe.py   # one-shot
```

**`gorgonas_dev` is the debugging partition**: probes, single-item checks,
verification passes, "does this script even start", and inspecting data that is
not reachable from the login node (if a path is invisible there, that is
expected — open an interactive job on a node that has it). It is capped at
**1h30**, default 10 minutes, so it is deliberately unsuitable for real runs.
Anything longer is an `sbatch` to a production partition.

## 4. The partitions and their hardware

Read them live rather than from memory:

```bash
sinfo -o "%P %a %l %D %N %c %m %G %h"
scontrol show partition
scontrol show node <name>
```

State as of 2026-09-01 (SLURM 23.02.4):

| | gorgonas | gorgonas_dev | medusas_shr |
|---|---|---|---|
| Nodes | gorgona5–7 | gorgona3, gorgona10 | medusa3–6 |
| CPUs / node | 32 (16 cores x2 threads) | 32 (16 x2) | 64 (32 cores x2) |
| Memory / node | 64 GB | 64 GB | 252 GB |
| GPUs as SLURM sees them | `Gres=(null)` | `Gres=(null)` | `gpu:2` |
| Time limit | unlimited (default 4d04h) | **1:30:00** (default 10 min) | **2 days** (default 1h) |
| Max nodes / job | 4 | **1** | 3 (`QoS=max3nodes`) |
| Sharing | EXCLUSIVE | EXCLUSIVE | `YES:4` |
| Default memory | whole node (64204 MB) | whole node | **1000 MB per CPU** |
| Default partition | yes | no | no |
| OS | Ubuntu (kernel 5.15) | Ubuntu (5.15) | EL9 (kernel 5.14) |

Consequences worth internalizing:

- **`Gres=(null)` does not mean "no GPU".** The gorgonas carry real cards that
  SLURM does not track — `AvailableFeatures=3090` on gorgona5, 6, 7 and 10;
  gorgona3 advertises no feature and is a different card. Since they are
  untracked, **never pass `--gres=gpu:1` to a gorgonas job**: the resource does
  not exist there, the request can never be satisfied, and the job sits
  `PENDING` forever. What keeps two jobs off one card there is
  `OverSubscribe=EXCLUSIVE` — one job per node. To select a card model, use
  `--constraint=3090`, which is a feature and does work.
- **On `medusas_shr` the GPU request is mandatory.** The partition is shared
  four ways; without `--gres=gpu:1` SLURM never sets `CUDA_VISIBLE_DEVICES`,
  the process reaches for a card someone else already holds, and it fails with
  `cudaSetDevice() … out of memory`. Drop `--exclusive` there too: asking for a
  whole 64-CPU node on a shared partition pushes the start out by days.
- **`DefMemPerCPU=1000` on the medusas** — a job that does not ask for memory
  gets 1 GB per CPU and is killed when it exceeds it. The gorgonas hand over
  the whole node by default, so a script moved from one to the other has to
  gain an explicit `--mem` or `--mem-per-cpu`.
- **`EXCLUSIVE` bounds array width.** With two nodes, a `gorgonas_dev` array
  runs at most two tasks at once; `MaxNodes=1` also forbids a multi-node job
  there. Size arrays to the node count instead of queueing tasks that cannot
  start.
- **A short job can be better off in the debug queue.** `gorgonas` has no time
  limit, so it fills with multi-day jobs and a 20-minute job can wait days
  behind them. Measure one unit first, then decide.

## 5. `EnforcePartLimits = NO` — the silent PENDING trap

A job asking for more than its partition's `MaxTime` is **accepted**: `sbatch`
returns a job id, and the job then sits `PENDING` with
`Reason=PartitionTimeLimit` forever — it never starts and never errors.
`sbatch --test-only` does not catch it either; it happily reports a start time.

So change `#SBATCH --time` in the same edit that changes `--partition`, and
after every submission confirm once:

```bash
squeue -j <jobid> -o "%i %T %R"
```

## 6. Read the log, not the exit code

- A driver script that catches per-item failures and continues still exits 0.
  **Count the artifacts it was supposed to produce**, not `sacct`'s state.
- `sacct` can report `TIMEOUT` for a job whose work finished — the process can
  hang after its last output without reaching the controller. The last real
  line in the log is the truth.
- When a framework swallows an error inside a worker, the traceback that
  matters is **near the top** of the log, not the exception at the bottom.

## 7. Environment on compute nodes

- **`$HOME` is not reachable from every node.** On the medusas it is not, and
  anything resolving `~` fails — tool caches fall back to `/tmp/...` and cannot
  create it. Point caches at shared storage from a single env file that every
  job script sources: `XDG_CACHE_HOME`, `MPLCONFIGDIR`, `KERAS_HOME`,
  `HF_HOME`, `TORCH_HOME`, `PIP_CACHE_DIR`.
- Compute nodes do have internet access, but **do not rely on a download
  inside a job**. Fetch pretrained weights, packages and datasets once, into a
  cache on shared storage, and let the job read from there — otherwise every
  array task re-downloads the same file, and a transient network failure kills
  a run that had nothing to do with the network.
- **Two SLURM clients exist on the login node.** The cluster's is under
  `/usr/local/slurm/bin` (23.02.4); a distro package also installs an older
  `/usr/bin/sinfo` with no usable config, which fails with
  `res_nsearch error: Unknown host`. `/etc/profile` fixes the order only for
  login shells, so non-login shells (VS Code terminals, some scripts) hit the
  broken copy. Before debugging any "SLURM is down" symptom, check
  `command -v sinfo` resolves under `/usr/local/slurm`.
- The two node families run different distributions, so a binary or environment built on a gorgona is not guaranteed to run on a medusa.

## 8. Storage

Read the layout live rather than from memory: `df -hT`, `mount`,
`stat -f <mount>`. State on the login node as of 2026-09-01:

| Mount | Type | Size | Free | What it is |
|---|---|---|---|---|
| `/snfs2` | BeeGFS (`sysMgmtdHost` 192.168.62.104) | 25 TB | 8.4 TB | **the main shared work area** — datasets, checkpoints, outputs |
| `/snfs1` | NFS (`sonik2`) | 2.0 TB | 1.4 TB | secondary shared area, under `/snfs1/speed/` |
| `/sonic_home` | NFS (`tails1`) | 3.3 TB | 899 GB | shared home, one folder per user (this is the cluster-wide home, not `/home`) |
| `/sonic_modules` | NFS (`tails1`) | 330 GB | 328 GB | shared software modules tree |
| `/sonic_etc` | NFS (`tails1`) | 30 GB | 30 GB | cluster config, including SLURM's `slurm.conf` |
| `/home` | **local disk on the login node** | 1.7 TB | 713 GB | not shared — see below |
| `/` | local disk on the login node | 94 GB | **9.8 GB** | do not write here |

**Each area is one subfolder per user**, named after the login: `/snfs2/<user>`
(28 entries), `/snfs1/speed/<user>` (18), `/sonic_home/<user>` (43). Alongside
them sit shared, non-user folders — `/snfs2/llm-models`, `/snfs1/llm-models`
and similar. **Write only inside your own subfolder**, and never delete or
modify anything in someone else's or in a shared model folder.

`/snfs2` is world-writable at the top level and the per-user folders are
typically group- and world-readable (`drwxrwxr-x`). Nothing there is private by
default: assume colleagues can read what you put on it, and `chmod` anything
sensitive yourself. That openness is also the reason a careless `rm -rf` with a
wrong path can destroy another person's work — check the path before deleting.

There are **no BeeGFS per-user quotas exposed** (`beegfs-ctl` is not installed
on the login node), so nothing stops one user filling 25 TB. Free space is a
shared, exhaustible resource: check `stat -f /snfs2` before a large write, and
clean up intermediates when a stage is finished.

**`$HOME` is not shared.** The login node's `/home` is a local disk on that
machine, which is exactly why home paths are unreachable from some compute
nodes (see section 7). Anything a job must read or write goes on `/snfs2`,
`/snfs1` or `/sonic_home` — never a path under the login node's `/home`, and
never `/`, which has under 10 GB free.

- **A full BeeGFS volume is reported as `Remote I/O error`, not `ENOSPC`** —
  run `stat -f <mount>` before concluding the mount is broken.
- Check free space *before* starting anything that writes hundreds of GB, and
  state the expected footprint up front.
- **Never rewrite a large data file in place.** Write `<name>.partial`, then
  `os.replace` it into position, one unit at a time; the old file stays intact
  until its replacement is complete on disk.
- Use a per-item **marker file written only after the write commits** as the
  resume signal. Counting markers is then a real check, not a restatement of
  the exit code.
- Reads on shared storage are often the bottleneck, not the GPU. A GPU idling
  between short bursts means the input pipeline is starving it; a faster card
  changes nothing, and neither does more workers past the point where storage
  saturates.
- `TmpDisk=0` on every node: there is no advertised local scratch to fall back
  on.

## 9. Measure before scaling up

Run one unit on `gorgonas_dev` and time it before submitting an array of a
thousand. The measured rate decides the array size, the walltime request, the
worker count and sometimes the partition. Guessing any of those wastes a queue
slot that someone else could have used.

## 10. Etiquette

The cluster is shared with the whole lab and the login node has no per-user
isolation. Ask for the smallest allocation that fits, release interactive
sessions as soon as they are done, avoid `--exclusive` on shared partitions,
keep array widths in line with what the partition can actually run, and do not
leave anything running that nobody is waiting on.
