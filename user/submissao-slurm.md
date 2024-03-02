# Como Submeter Jobs?

Existem dois tipos principais de jobs: interativos e batch jobs:

## Jobs interativos

Embora não seja possível logar diretamente em um nó de computação quando quiser, é possível submeter um job para acessar nós diretamente. Ou seja, é submetido um job que retorna um terminal para os recursos alocados. Novamente, enquanto você tiver uma alocação, ninguém mais terá acesso aos recursos alocados a você nesse período de alocação. No tempo que você tiver alocado você poderá rodar o que quiser, ou até mesmo ficar sem rodar nada. Esse modo de alocação é recomendado para usuários que ainda estão no processo de preparação dos experimentos, testando sua aplicação em ambiente real de execução. Essa alocação pode ser alcançada da seguinte forma: 

```console
user@phocus4:~$ srun -w gorgona10 --time 1:00:00 --pty bash
srun: job 1704 queued and waiting for resources
srun: job 1704 has been allocated resources
user@gorgona10:~$
```
No comando acima, o nó específico gorgona10 será alocado por um período máximo de 1 hora. Porém, é possível que você não queira uma máquina específica, mas qualquer máquina em uma fila específica (filas são abordadas mais à frente):

```console
user@phocus4:~$ srun -N 2 -p gorgonas --time 00:20:00 --pty bash
srun: job 1705 queued and waiting for resources
srun: job 1705 has been allocated resources
user@gorgona2:~$
```

Agora são pedidos 2 nós quaisquer da fila gorgonas por um período de 20 min. Sim, é possível pedir quantos nós quiser. Ao pedir por mais de 1 nó, a sua sessão de terminal irá para um dos nós, porém é possível usar todos os nós alocados via mpirun.

Tendo terminado de usar os nós alocados é interessante retornar os recursos à fila. Por um lado, isso ajuda seus colegas pesquisadores, reduzindo o desperdicio de recursos e poupando o tempo de todos. Por outro lado, todo tempo gasto em alocações reduz a sua prioridade, então é possível que mais a frente você terá que esperar mais para ter seus jobs executados do que se não houvesse desperdiçado tempo agora. Para cancelar sua alocação interativa basta usar o comando ‘exit’ ou Ctrl+d. Caso a conexão com os nós tenha caído por problemas de rede, o job não é finalizado. Neste caso deve-se ou reconectar com o nó que foi alocado (NÃO IMPLEMENTADO AINDA) ou cancelar seu job via scancel (a ver a frente).

 O comando srun é padrão do Slurm, com uma página *man* e com muito material disponível online para casos de usos mais complexos.

## Batch jobs

Normalmente, rodar um experimento não é simplesmente executar apenas um comando. Comummente é necessário mudar arquivos, preparar um ambiente de teste, testar aplicações com configurações diferentes, replicar execuções, etc. Para isso é interessante colocar todas essas operações em um único script bash e rodá-lo. Esta é inclusive uma forma interessante de se trabalhar, melhorando a reprodutibilidade dos seus experimentos e reduzindo o tempo de trabalho manual em execuções com diferentes configurações. Outro aspecto interessante é que como se trata de um bash script, este pode ser executado em qualquer máquina Linux. O Slurm disponibiliza uma forma simples de trabalhar dessa forma, via Batch jobs: 

```console
user@phocus4:~$ sbatch meu_script.sh param1 param2
Submitted batch job 1706
user@phocus4:~$
```

No comando acima, o script bash meu_scipt.sh é submetido ao Slurm para execução. Esse é um job fire-and-forget, onde você só precisará se preocupar com a saída ao fim da execução.

O mínimo necessário para um batch job é um script e definições dos recursos a serem usados (filas, nós, tempo). Essas definições podem ser passadas para o slurm via parâmetros do sbatch ou pelo próprio script:

```bash
#!/bin/bash
#SBATCH --job-name=my_little_job  # Job name
#SBATCH --time=00:05:00       	  # Time limit hrs:min:sec
#SBATCH -N 1            	        # Number of nodes
#SBATCH --mail-type=ALL
#SBATCH --mail-user=my_mail@mail.com

set -x # all comands are also outputted

cd /home_cerberus/speed/username

module list
module avail
module load python3.12.1

source myenv1/bin/activate

python3 test.py

hostname   # just show the allocated node
```

O script acima foi feito para rodar o seguinte código python:

```python3
# test.py
import numpy as np

a=np.array([1,2,3])

print(f'{a[1:]}')
```

Para submeter o job basta:

```command
username@phocus4:/home_cerberus/speed/username$ sbatch run.sh 
Submitted batch job 1707
username@phocus4:/home_cerberus/speed/username$ cat slurm-1707.out
+ cd /home_cerberus/speed/username
No Modulefiles Currently Loaded.
--------------------------- /opt/Modules/modulefiles ---------------------------
anaconda3.2023.09-0  module-git   modules  python3.12.1  
dot                  module-info  null     use.own       
+ python3 test.py
[2 3]
+ hostname
gorgona7
slurmstepd: error: _cgroup_procs_check: failed on path (null)/cgroup.procs: No such file or directory
slurmstepd: error: Cannot write to cgroup.procs for (null)
slurmstepd: error: Unable to move pid 351386 to init root cgroup (null)
```

Ao usar ‘#SBATCH’ no seu script, você estará passando parâmetros ao sbatch. Esses parâmetros são iguais aos de srun, podendo ser passados diretamente para sbatch. Alguns parâmetros interessantes de se conchecer são:
 - **time**: tempo máximo do job.
 - **N**: número de nós a serem alocados.
 - **job-name**: nome do seu job, que aparecerá na fila (ajuda quando são submetidos vários jobs).
 - **mail-coisas**: envia um email com o status do seu job Com o type ALL é enviado um email quando o seu job começa a executar e quando termina de executar (independentemente do motivo, e.g., acabou, timeout, foi cancelado, nó caiu).

Existe outra vantagem de usar o sbatch: os logs de saída. Todo job submetido via sbatch gera um arquivo ‘slurm-1707.out’ (sendo 1707 o ID do job) com o stdout e stderr do script executado. Esse arquivo .out é gerado no mesmo local de onde o comando sbatch foi invocado. Uma dica é usar o comando ‘set -x’ em seus scripts. Esse comando faz com que todos os comandos executados saiam no stdout. Exemplo, a primeira linha de ‘slurm-1707.out’ do script exemplo será ‘+ cd /path/of/my/code’.

## Gerenciando jobs

É possível acompanhar seus jobs submetidos por meio do comando squeue:

```command
username@phocus4:/home_cerberus/speed/username$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
              1711  gorgonas my_littl willianj PD       0:00      1 (Resources)
              1686  gorgonas  dada_al rodrigo.  R   15:04:33      1 gorgona6
              1699  gorgonas     bash gabriel.  R    1:06:42      1 gorgona2
              1678  gorgonas  ecg_job pedrorob  R   20:29:10      1 gorgona7
              1669  gorgonas  ecg_job pedrorob  R 1-01:00:36      1 gorgona4
```

O comando squeue retorna a fila do cluster inteiro, com o status dos jobs, tempo que estão em execução, recursos usados e o ID do job. Esse ID é único no cluster, independente da fila ou usuário. É recomendado usar ‘squeue | grep username’ para filtrar apenas os seus jobs. O campo de state (ST) representa o estado do job, sendo os mais comuns PD (pending) e R (running). É recomendado ler guias online sobre squeue para verificar outras informações pertinentes desses campos.

Caso necessário é possível cancelar um job manualmente. Por exemplo, um usuário pode ter submetido um job com os parâmetros errados, ou ter verificado que o resultado já está errado antes do fim do experimento. Nesse caso basta rodar o seguinte comando com o ID do seu job:

```command
username@phocus4:/home_cerberus/speed/username$ scancel 524
username@phocus4:/home_cerberus/speed/username$
```

Outro comando interessante é o sinfo, que mostra o status do cluster com todos os nós disponíveis. Novamente, este é um cluster Slurm, então os comandos, parâmetros e saídas são padronizados, tendo muita informação online de como usa e o que significa cada campo:

```command
username@phocus4:/home_cerberus/speed/username$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
gorgonas*    up   infinite      2  drain gorgona[1,5]
gorgonas*    up   infinite      4  alloc gorgona[2,4,6-7]
gorgonas*    up   infinite      2   idle gorgona[3,10]
username@phocus4:/home_cerberus/speed/username$
```

## TLDR
 - Alocação interativa:  srun -p gorgonas --time 00:20:00 --pty bash
 - Batch job: sbatch job.sh
 - Usar alocações interativas para preparar os experimentos e depois montar scripts para automatizar os experimentos com batch jobs.
 - Usar exemplo de batch job acima.
 - Usar squeue para verificar o status dos jobs submetidos.
 - Não esquecer de encerrar alocações interativas.
 - Usar scancel para cancelar jobs.
 - Usar sinfo para ver o status do cluster.
