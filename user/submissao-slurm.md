# Como Submeter Jobs?

Existem dois tipos principais de jobs: interativos e batch jobs. A diferença é que os jobs interativos servem para quando você ainda está testando seu código e (obviamente) você não conseguiu rodá-lo localmente. Os batch jobs é quando você já tem o código pronto e/ou você tem que escalar o projeto. Vamos detalhar cada um deles a seguir.

## Pré-requisitos
Na primeira interação com o cluster você deve garantir que suas pastas de uso pessoal estão devidamente configuradas. Para isso, sugere-se primeiro rodar os seguintes comandos, conforme demonstrado abaixo:
```console
user@phocus4:~$ pwd
/home/<grupo>/<user>
user@phocus4:~$ls -a
snap
```
Se isso aparecer significa que você já está dentro da sua pasta local. Se você tentar conectar direto no console das gorgonas com o comando abaixo retornará o seguinte erro:

```console
user@phocus4:~$ srun --partition=gorgonas --time=1:00:00 --pty bash
slurmstepd: error: couldn't chdir to `/home/<grupo>/<user>': No such file or directory: going to /tmp instead
slurmstepd: error: couldn't chdir to `/home/<grupo>/<user>': No such file or directory: going to /tmp instead
user@gorgona1:/tmp$
```
Vamos entender o comando:
```console
srun --partition=gorgonas --time=1:00:00 --pty bash
```
`srun` significa: "rode esse comando no cluster". <br>
`--partition=gorgonas`  especifica qual o conjunto de máquinas que você quer usar sem especificar uma gorgona, deixando para o Slurm te alocar uma máquina que não tenha jobs rodando.<br>
`--time=1:00:00` especifica por quanto tempo você pretende testar seus experimentos no bash<br>
`--pty bash` o bash que por sua vez é aberto com esse parametro. Este bash é análogo ao prompt de comando do seu PC, só que da gorgona para o qual você foi alocado para o Slurm<br>

Esse erro encontra-se detalhado em [Storage](storage.md):

"Outro detalhe importante é: assuma que, exceto por '/home/all_home/', nenhum usuário tem acesso a qualquer outro arquivo ou path local dos nós de computação. Por exemplo, um path de sua home '/home/pos/username' não tem acesso liberado ao usuário 'username'"<br>
Ou seja: /home/pos não existem nas gorgonas.<br>
Enquanto os diretórios: `/home_cerberus/disk2/<user>` são o "acesso a um espaço de armazenamento visível pelo cluster inteiro" citado em: [Como funciona?](como-funciona.md)
Portanto, antes de rodar o comando mude seu diretório para `/home_cerberus/disk2/<user>`. E certifique-se de ter usa \home_cerberus configurada. Para isso digite no prompt de comando:

```console
user@phocus4:~$ cd \home_cerberus
user@phocus4:/home_cerberus$ls -a
apt-proxy  aquota.user  bla2  cache  disk2  disk3  grad  hadoop  hdfs_namenode  lost+found  speed  vvsd
```
Escolha a partição do disco que você quer usar `disk2` ou `disk3` e se já não houver crie uma pasta com seu nome de usuário. **Tem que ser exatamente igual ao seu usuário**. Para saber qual disco usar pode-se rodar um comando `df -h` para saber como cada partição está sendo usada, e quais os recursos disponíveis.

```console
user@phocus4:~$df -h
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           1.6G  3.5M  1.6G   1% /run
/dev/sda2        94G   28G   61G  32% /
tmpfs           7.9G  8.0K  7.9G   1% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
efivarfs         72K   47K   21K  70% /sys/firmware/efi/efivars
/dev/sda1       476M  6.1M  469M   2% /boot/efi
/dev/sda4       1.7T  457G  1.2T  28% /home
tmpfs           1.6G   76K  1.6G   1% /run/user/127
cerberus:/home  826G  654G  130G  84% /home_cerberus
tmpfs           1.6G   60K  1.6G   1% /run/user/5778
tmpfs           1.6G   60K  1.6G   1% /run/user/5822
tmpfs           1.6G   60K  1.6G   1% /run/user/4518
tmpfs           1.6G   60K  1.6G   1% /run/user/6968
tmpfs           1.6G   56K  1.6G   1% /run/user/0
tmpfs           1.6G   60K  1.6G   1% /run/user/6933
tmpfs           1.6G   60K  1.6G   1% /run/user/9647
tmpfs           1.6G   60K  1.6G   1% /run/user/5322
tmpfs           1.6G   60K  1.6G   1% /run/user/9083
tmpfs           1.6G   60K  1.6G   1% /run/user/5712
tmpfs           1.6G   60K  1.6G   1% /run/user/9071
tmpfs           1.6G   60K  1.6G   1% /run/user/6397
tmpfs           1.6G   60K  1.6G   1% /run/user/4550
tmpfs           1.6G   60K  1.6G   1% /run/user/7485
tmpfs           1.6G   60K  1.6G   1% /run/user/5680
user@phocus4:~$ cd \disk2
user@phocus4:/home_cerberus/disk2$mkdir <user>
```

Uma vez feito esses passos vamos dar continuidade:

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

### Exemplo Hands-On
Na prática, uma vez que você está dentro da gorgona, você pode rodar seu programa normalmente como você faria em seu computador. Para submeter os batch jobs você precisará em essência de dois arquivos: um .sh para configurar o ambiente, baixar dependências e rodar o código e um .py que é o código em si.  Abaixo um exemplo de interação com os seguintes passos:

1. Abrir uma conexão com alguma gorgona que esteja disponível
```console
user@phocus4:~$ srun --partition=gorgonas --time=1:00:00 --pty bash
```
2. Verifique os modulos disponíveis:
```console
user@phocus4:~$ module avail
----------------------------------------------- /opt/Modules/modulefiles -----------------------------------------------
anaconda3.2023.09-0  cuda/11.8.0  cuda/12.3.2  module-info  modules  python3.7.6  python3.10.12  python3.12.1

Key:
modulepath
```
Escolha um dos módulos e rode um programinha:
```console
user@gorgona1:/home_cerberus/disk2/user$ module load python3.10.12
user@gorgona1:/home_cerberus/disk2/user$ python3
Python 3.10.12 (tags/v3.10.12:b4e48a444e, Feb  6 2024, 12:12:45) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print ("Hello Word")
Hello Word
>>>
```

Caso queira criar ou subir algum arquivo, seguem algumas possibilidades de comandos:

Exemplo Vim:
```console
user@phocus4:~$ vim nome_arquivo.py
```
Exemplo Git:
```console
user@phocus4:~$ git clone <url>
```

Exemplo upload: 
```console
scp /path/local/do/meu/arquivo.txt phocus4:/home_cerberus/disk2/meu_username/
```

Para instalar dependências do seu código é necessário criar um venv. Nele você tem autorização para instalar pacotes conforme sua necessidade. Para configurar um venv na mão. Faça:
```console
user@gorgona1:/home_cerberus/disk2/user$ python3 -m venv nome_venv
```

Caso haja problemas conforme relatado em [FAQ](faq.md#3-não-estou-conseguindo-mais-criar-um-venv-na-home_cerberus). Mude seu diretório de: `/home_cerberus/disk2/user` para `/home/all_home/user/` e faça:

```console
user@gorgona1:/home/all_home/user/$ python3 -m venv /home/all_home/user/nome_venv/
user@gorgona1:/home/all_home/user/$ source /home/all_home/larissa.gomide/exp_notebook_venv/bin/activate 
```

Lembrando que o comando source acima ativa o venv e para desativa-lo basta digitar `deactivate`.
Obs: Sim, em essência você tem três pastas em diferentes lugares para colocar seus arquivos.

Uma vez que seu código está rodando certinho, certifique-se que o seu script bash também está configurado corretamente:
```console
user@gorgona1:/home/all_home/user/$ bash nome_arquivo.sh
```

Para exemplos de bash vide a pasta: [Exemplos](Exemplos).

Antes do próximo passo, encerre sua conexão com o prompt da gorgona alocada e volte para a `user@phocus4`
```console
user@gorgona1:/home/all_home/user/$ exit
user@phocus4:~$
```

Tudo pronto? Hora de submeter o job. 

## Batch jobs

Normalmente, rodar um experimento não é simplesmente executar apenas um comando. Comummente é necessário mudar arquivos, preparar um ambiente de teste, testar aplicações com configurações diferentes, replicar execuções, etc. Para isso é interessante colocar todas essas operações em um único script bash e rodá-lo. Esta é inclusive uma forma interessante de se trabalhar, melhorando a reprodutibilidade dos seus experimentos e reduzindo o tempo de trabalho manual em execuções com diferentes configurações. Outro aspecto interessante é que como se trata de um bash script, este pode ser executado em qualquer máquina Linux. O Slurm disponibiliza uma forma simples de trabalhar dessa forma, via Batch jobs: 

```console
user@phocus4:~$ sbatch meu_script.sh param1 param2
Submitted batch job 1706
user@phocus4:~$
```

No comando acima, `sbatch` significa "coloque esse script na fila de execução". O script bash meu_scipt.sh é submetido ao Slurm para execução. Esse é um job fire-and-forget, onde você só precisará se preocupar com a saída ao fim da execução.

O mínimo necessário para um batch job é um script e definições dos recursos a serem usados (filas, nós, tempo). Essas definições podem ser passadas para o slurm via parâmetros do sbatch ou pelo próprio script. O exemplo abaixo também está disponível em: [Exemplos](Exemplos):

```bash
#!/bin/bash
#SBATCH --job-name=my_little_job  # Job name
#SBATCH --time=00:05:00           # Time limit hrs:min:sec
#SBATCH -N 1                        # Number of nodes
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
username@phocus4:/home_cerberus/speed/username$ sbatch simple_bash.sh 
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

As últimas 3 linhas do output acima são "normais". Isso significa: elas vão aparecer e não tem com o que se preocupar.

Ao usar ‘#SBATCH’ no seu script, você estará passando parâmetros ao sbatch. Esses parâmetros são iguais aos de srun, podendo ser passados diretamente para sbatch. Alguns parâmetros interessantes de se conchecer são:
 - **time**: tempo máximo do job.
 - **N**: número de nós a serem alocados.
 - **job-name**: nome do seu job, que aparecerá na fila (ajuda quando são submetidos vários jobs).
 - **mail-coisas**: envia um email com o status do seu job Com o type ALL é enviado um email quando o seu job começa a executar e quando termina de executar (independentemente do motivo, e.g., acabou, timeout, foi cancelado, nó caiu).

Existe outra vantagem de usar o sbatch: os logs de saída. Todo job submetido via sbatch gera um arquivo ‘slurm-1707.out’ (sendo 1707 o ID do job) com o stdout e stderr do script executado. Esse arquivo .out é gerado no mesmo local de onde o comando sbatch foi invocado. Uma dica é usar o comando ‘set -x’ em seus scripts. Esse comando faz com que todos os comandos executados saiam no stdout. Exemplo, a primeira linha de ‘slurm-1707.out’ do script exemplo será ‘+ cd /path/of/my/code’.

No script é carregado um python de versão específica usando environment modules, visto em detalhes em [Dependências](gerencia-de-deps.md).

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
___

## TLDR
 - Alocação interativa:  srun -p gorgonas --time 00:20:00 --pty bash
 - Batch job: sbatch job.sh
 - Usar alocações interativas para preparar os experimentos e depois montar scripts para automatizar os experimentos com batch jobs.
 - Usar exemplo de batch job acima.
 - Batch jobs sempre deixam um log da execução em um arquivo slurm-ID.out no local de onde foi submetido.
 - Usar squeue para verificar o status dos jobs submetidos.
 - Não esquecer de encerrar alocações interativas.
 - Usar scancel para cancelar jobs.
 - Usar sinfo para ver o status do cluster.

 ___

 ## Tabelinha de comandos essenciais

Comandos Slurm (Sem risco):<br>
 `srun` significa: "rode esse comando no cluster"<br>
 `sbatch` significa "coloque esse script na fila de execução"<br>
 `squeue` vê a lista de jobs em execução<br>
 `scancel` cancela a execução de um job - precisa do job ID<br>
 <br>

Comandos Terminal (Sem risco):<br>
  cd, cp, ls, pwd,

Comandos Terminal (Pouco risco, reversível):<br>
  mv, chmod

Comandos Terminal (Muito risco , irreversível, tem que tomar cuidado):<br>
  rm

Comandos Git (sem risco):<br>
 git clone