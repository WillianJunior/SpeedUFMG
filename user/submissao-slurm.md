# Como Funciona o Cluster?

Para seguir essa documentação, asusme-se que você já tem acesso ao nó de login `phocus4`. Existem duas formas de usar as máquinas do cluster: (i) acessando alguma máquina direamente ou (ii) submetendo um script com seus programas/testes a serem executados. Chamamos essas máquina de nós computacionais (ou apenas nós). Ao acessar uma máquina (ou nó) é garantido que só você terá acesso a ela. Esse acesso tem uma duração máxima de tempo que você pode pedir. Chamamos essas alocações de *jobs*. Jobs são compostos pelos recursos pedidos e o tempo requisitado. Por exemplo, pode-se pedir "quero 1 nó com a GPU 4090 por no máximo 20 horas", ou "gostaria de 2 nós, cada um com 2 GPUs 5090 por 30 minutos". 

Além de você, existem outros usuários do cluster querendo alocações de jobs. Todos usuários pedem recursos por meio de jobs, sendo esses jobs enfileirados automaticamente. Assim que os recursos necessários para o primeiro job da fila estiverem disponíveis, ele será executado. Quando jobs encerram, os recursos (nós) são liberados, e podem ser usados por outros jobs. Como existem vários nós, vários jobs podem estar em execução em um dado momento. Adicionalmente, é possível submeter quantos jobs forem necessários, não havendo limite de uso. Ou seja, se o cluster estiver livre, nada lhe impede de usar 10 ou mais nós ao mesmo tempo para 10 jobs diferentes. Porém, o cluster tentará dividir o tempo de uso igualmente entre seus usuários. Caso você submeta 100 jobs em 24 horas quando ninguém estava usando o cluster, e em seguida aparecem novos jobs de outros usuários, seus jobs terão menos prioridade. O uso do cluster é medido em tempo com jobs em execução.

# Acessando Nṍs Diretamente - Sessões Interativas

A primeira forma de acessar nós é por meio de uma sessão interativa. Nesse modelo, você submeterá um job de alocação, e quando alocados os recursos, poderá acessá-los via terminal.

```console
username@phocus4:~$ srun --partition=gorgonas --time=1:00:00 --pty bash
srun: job 16212 queued and waiting for resources
srun: job 16212 has been allocated resources
username@gorgona3:~$
```

Vamos entender o comando acima:

```console
srun --partition=gorgonas --time=1:00:00 --pty bash
```
`srun` significa: "rode esse comando no cluster". <br>
`--partition=gorgonas`  especifica qual o conjunto de máquinas que você quer usar. A configuração dos nós disponíveis no cluster estão [aqui](nodes.md). <br>
`--time=1:00:00` especifica por quanto tempo você gostaria de alocar os recursos. Ao fim desse tempo o job será forçosamente encerrado, independente do que esteja rodando.<br>
`--pty bash` indica que a aplicação `bash` será aberta para você (i.e., terminal). Este bash é análogo ao prompt de comando do seu PC, só que do nó alocado a você.<br>

Ao encerrar o terminal (e.g., comando `exit`) o job será terminado, e o recurso poderá ser usado por outros jobs. Caso sua conexão de internet caia enquanto você está em uma sessão interativa da forma acima, sua alocação poderá ser encerrada em algum momento, mesmo que você volte a se conectar com o nó alocado. Para realizar uma alocação de um nó de forma mais permanente, é possível usar o seguinte comando:

```console
username@phocus4:~$ salloc -p gorgonas --time=1:00:00
salloc: Granted job allocation 16214
salloc: Nodes gorgona3 are ready for job
username@phocus4:~$ ssh gorgona3
Last login: Thu Feb 26 17:43:51 2026 from 192.168.62.4
username@gorgona3:~$ 
```

Note que os mesmo argumentos do `srun` valem para o `salloc`. Em seguida, é possível acessar diretamente (sem senha) o nó alocado. Você poderá se desconectar e reconectar via ssh quantas vezes vocês quiserem, enquanto possuirem a alocação. Por meio do comando `exit` pode-se fechar a conexão com um nó de computação ou encerrar a sua alocação.

```console
username@gorgona3:~$ exit
logout
Connection to gorgona3 closed.
username@phocus4:~$ exit
exit
salloc: Relinquishing job allocation 16215
salloc: Job allocation 16215 has been revoked.
username@phocus4:~$ 
```

Como mencionado, não é possível acessar um nó que não lhe foi alocado:

```console
username@phocus4:~$ ssh gorgona10
Access denied by pam_slurm_adopt: you have no active jobs on this node

Connection closed by 192.168.62.40 port 22
username@phocus4:~$
```

# Gerenciando Seus Jobs

A fila de execução pode ser vista por meio do comando `squeue`, que mostra todos os jobs em execução (State=Running: ST=R) e esperando na fila (State=Pending: ST=PD). Para cada job é mostrado o ID do job, a partição usada, os nós alocados e o tempo atual de execução.

```console
username@phocus4:~$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
             16188  gorgonas test_all user123  PD       0:00      1 (Resources)
             16079  gorgonas TimesNet user658   R 3-20:18:33      1 gorgona4
             16070  gorgonas depressi user557   R 4-02:04:58      1 gorgona5
             16216  gorgonas visual_p user109   R       0:17      1 gorgona10
             16210   medusas     bash user987   R      18:10      1 medusa6

```

Jobs podem ser cancelados a qualquer momento via comando `scancel <JOBID>`. Não é possível cancelar um job de outro usuário:

```console
username@phocus4:~$ scancel 16070
scancel: error: Kill job error on job id 16070: Access/permission denied
username@phocus4:~$
```

Também é possível ver quais nós estão ou não disponíveis via `sinfo`:

```console
username@phocus4:~$ sinfo
PARTITION    AVAIL  TIMELIMIT  NODES  STATE NODELIST
medusas         up 2-00:00:00      2  alloc medusa[4,6]
medusas_shr     up 2-00:00:00      1  alloc medusa5
gorgonas*       up   infinite      4  alloc gorgona[4-5,7,10]
gorgonas*       up   infinite      2   idle gorgona[3,6]
gorgonas_dev    up      30:00      1  alloc gorgona10
```

A marcação * na partição `gorgonas` indica que esta é a partição default. Ou seja caso não seja informada a partição (`-p`) será solicitado um nó da partição `gorgonas`.

Outro detalhe importante que é mostrado pelo `sinfo` são os STATEs. Neles são mostrados o estado de cada nó. Os estados mais importantes de se conhecer são: idle (livre para uso), alloc (completamente alocado para um ou mais jobs), mix(partialmente alocado para um ou mais jobs), drain (removido da fila para manutenção), down (fora da fila por problema no nó, reporte no grupo do telegram se vir isso) e comp (com um job em estado de finalização). Outra coisa que pode aparecer no STATE é um asterisco, significando que a máquina está inacessível, mesmo para o slurm (e.g., down* significa que a máquina pode estar desligada).

# Batch jobs

Normalmente, rodar um experimento não é simplesmente executar apenas um comando. Comummente é necessário mudar arquivos, preparar um ambiente de teste, testar aplicações com configurações diferentes, replicar execuções, etc. Para isso é interessante colocar todas essas operações em um único script bash e rodá-lo. Esta é inclusive uma forma interessante de se trabalhar, melhorando a reprodutibilidade dos seus experimentos e reduzindo o tempo de trabalho manual em execuções com diferentes configurações. Outro aspecto interessante é que como se trata de um bash script, este pode ser executado em qualquer máquina Linux. O Slurm disponibiliza uma forma simples de trabalhar dessa forma: via Batch jobs: 

```console
username@phocus4:~$ sbatch meu_script.sh param1 param2
Submitted batch job 16078
username@phocus4:~$
```

No comando acima, `sbatch` significa "quero executar o script `meu_script.sh` em um job". O script é submetido ao Slurm para execução. Esse é um job do tipo [fire-and-forget](https://en.wikipedia.org/wiki/Fire-and-forget), onde você só precisará se preocupar com a saída ao fim da execução.

Em um script para batch job é possível definir os recursos a serem usados (filas, nós, tempo). Essas definições podem ser passadas para o slurm via parâmetros do `sbatch` ou pelo próprio script. O exemplo abaixo também está disponível em: [Exemplos](Exemplos):

```bash
#!/bin/bash
#SBATCH --job-name=my_little_job  # Job name
#SBATCH --time=00:05:00           # Time limit hrs:min:sec
#SBATCH -N 1                      # Number of nodes
#SBATCH --mail-type=ALL
#SBATCH --mail-user=my_mail@mail.com

set -x # all comands are also outputted

cd /snfs2/username/my_test_path

module list
module avail
module load python3.12.1

python3 test.py

hostname   # just show the allocated node
```

Ao usar `#SBATCH` no seu script, você estará passando parâmetros ao `sbatch` pelo seu script. Esses parâmetros são iguais aos de `srun`, podendo ser passados diretamente para `sbatch`. Alguns parâmetros interessantes de se conchecer são:
 - **time**: tempo máximo do job.
 - **N**: número de nós a serem alocados.
 - **job-name**: nome do seu job, que aparecerá na fila (ajuda quando são submetidos vários jobs).
 - **mail-coisas**: te avisa por email o que está acontecendo com o seu job. Com o type ALL é enviado um email quando o seu job começa a executar (também mostrando o tempo que passou na fila) e quando termina de executar (independentemente do motivo, e.g., acabou, timeout, foi cancelado, nó caiu). Ou seja: mande seus jobs e vá tomar um cafezinho até receber um email que ele terminou.

O script acima foi feito para rodar o seguinte exemplo python:

```python3
# test.py
a = [1,2,3]
print(f'{a[1:]}')
```

Para submeter o job basta:

```command
username@phocus4:~$ sbatch simple_bash.sh 
Submitted batch job 1707
username@phocus4:~$ cat slurm-1707.out
+ cd /snfs2/username/my_test_path
No Modulefiles Currently Loaded.
--------------------------- /opt/Modules/modulefiles ---------------------------
anaconda3.2023.09-0  cuda/11.8.0  cuda/12.8.0     python/3.12.1  
apptainer/1.4.2      cuda/12.3.2  python/3.7.6    uv/0.8.9       
cuda/11.1            cuda/12.6.2  python/3.10.12  

Key:
modulepath  
+ python3 test.py
[2 3]
+ hostname
gorgona7
```

Existe outra vantagem de usar o batch jobs comparado a sessões interativas: os logs de saída. Todo job submetido via sbatch gera um arquivo `slurm-1707.out` (sendo 1707 o ID do job) com o `stdout` e `stderr` do script executado. Esse arquivo .out é gerado no mesmo local de onde o comando sbatch foi invocado. Uma dica é usar o comando `set -x` em seus scripts. Esse comando faz com que todos os comandos executados saiam no `stdout`. Exemplo, a primeira linha de  `slurm-1707.out` do script exemplo foi `+ cd /snfs2/username/my_test_path`, mostrando que esse comando foi executado.


# Exemplo Hands-On
Na prática, uma vez que você está dentro de uma gorgona você pode rodar seu programa normalmente como você faria em seu computador. Para submeter os batch jobs você precisará em essência de dois arquivos: um .sh para configurar o ambiente, baixar dependências e rodar o código, e o código em si (e.g., um .py).  Abaixo um exemplo de interação com os seguintes passos:

1. Abrir uma conexão com alguma gorgona que esteja disponível
```console
username@phocus4:/snfs2/username$ srun --partition=gorgonas --time=1:00:00 --pty bash
username@gorgona3:/snfs2/username$
```

2. Verifique os modulos disponíveis:
```console
username@phocus4:/snfs2/username$ module avail
----------------------------------------------- /opt/Modules/modulefiles -----------------------------------------------
anaconda3.2023.09-0  cuda/11.8.0  cuda/12.3.2  module-info  modules  python3.7.6  python3.10.12  python3.12.1

Key:
modulepath
```

Escolha um dos módulos e rode um programinha:
```console
username@gorgona3:/snfs2/username$ python3 --version
Python 3.10.9
username@gorgona3:/snfs2/username$ module load python3.10.12
username@gorgona3:/snfs2/username$ python3
Python 3.10.12 (tags/v3.10.12:b4e48a444e, Feb  6 2024, 12:12:45) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print ("Hello Word")
Hello Word
>>>
```

Caso queira criar ou subir algum arquivo, seguem algumas possibilidades de comandos:

Exemplo Vim:
```console
username@phocus4:/snfs2/username$ vim nome_arquivo.py
```

Exemplo Git:
```console
username@phocus4:/snfs2/username$ git clone <url>
```

Exemplo upload (note que você estará executando esse comando da sua máquina, não da `phocus4`): 
```console
scp /path/local/do/meu/arquivo.txt phocus4:/snfs2/username
```

Para instalar dependências python do seu código é necessário criar um venv. Nele você tem autorização para instalar pacotes conforme sua necessidade. Para criar um venv faça:
```console
username@phocus4:/snfs2/username$ python3 -m venv nome_venv
username@phocus4:/snfs2/username$ source nome_venv/bin/activate
(nome_venv) username@phocus4:/snfs2/username$
```

Lembrando que o comando source acima ativa o venv e para desativa-lo basta digitar `deactivate`.

Uma vez que seu código está rodando certinho, certifique-se que o seu script bash também está configurado corretamente. Para isso, execute em um nó de computação:
```console
username@gorgona3:/snfs2/username$ bash nome_arquivo.sh
```

Para exemplos de bash vide: [Exemplos](Exemplos).

Antes do próximo passo, encerre sua conexão com o prompt da gorgona alocada e volte para a `phocus4`
```console
username@gorgona3:/snfs2/username$ exit
username@phocus4:~$
```

Tudo pronto? Hora de submeter jobs usando `sbatch nome_arquivo.sh`.

# Nós Compartilhados

Nem sempre é necessário usar todos os recursos de uma máquina. Por exemplo, as `medusas` possuem 2 GPUs RTX 5090. Talvez você tenha um job que consiga usar eficientemente apenas 1 GPU. Neste caso, não faz sentido desperdiçar o tempo da outra GPU parada. Para isso, partições com o sufixo `_shr` possuem nós de uso compartilhado. Embora mais de um job possa executar simultaneamente em tais nós, apenas 1 job por vez terá acesso a recursos individuais. Por exemplo, se uma `medusa` tem 2 GPUs, cada GPU poderá ser alocada apenas para 1 único job ao mesmo tempo. Notem que ainda é possível pedir ambas GPUs para um único job. Analogamente, os recursos de CPU (cores) e memória são rateados por GPU. Dado que uma `medusa`tem 2 GPUs, ao se pedir uma das GPUs, também serão alocados 50% da memória e dos cores de CPU para o mesmo job. Ou seja, não tem como um outro job atrapalhar o seu, por exemplo, alocando toda a memória do nó.

Para pedir alocações nesses nós, é necessário (i) informar a partição, já que essas não são partições default, e (ii) informar o número de GPUs necessárias. **Importante: caso não seja informado o número de GPUs, será alocado apenas 1 core de CPU! Ou seja, seu job não terá acesso a nenhuma GPU.** A seguir, um exemplo de alocação requisitando apenas 1 GPU e pedindo para mostrar as GPUs disponíveis para uso em um job:

```console
username@phocus4:/snfs2/username$ srun --gres=gpu:1 -pmedusas_shr nvidia-smi
Fri Mar 27 12:08:07 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.211.01             Driver Version: 570.211.01     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5090        Off |   00000000:41:00.0 Off |                  N/A |
|  0%   41C    P1             83W /  575W |       9MiB /  32607MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
username@phocus4:/snfs2/username$ 
```

Notem abaixo que se forem pedidas 2 GPUs, elas estarão disponíveis:

```console
username@phocus4:/snfs2/username$ srun --gres=gpu:2 -pmedusas_shr nvidia-smi
Fri Mar 27 12:08:07 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.211.01             Driver Version: 570.211.01     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5090        Off |   00000000:41:00.0 Off |                  N/A |
|  0%   41C    P1             83W /  575W |       9MiB /  32607MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA GeForce RTX 5090        Off |   00000000:83:00.0 Off |                  N/A |
|  0%   46C    P1             81W /  575W |       9MiB /  32607MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                                
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
username@phocus4:/snfs2/username$ 
```


___

## TLDR
 - Alocação interativa:  `srun -p gorgonas --time 00:20:00 --pty bash`
 - Batch job: `sbatch job.sh`
 - Usar alocações interativas para preparar os experimentos e depois montar scripts para automatizar os experimentos com batch jobs.
 - Usar exemplo de batch job acima.
 - Batch jobs sempre deixam um log da execução em um arquivo slurm-ID.out no local de onde foi submetido.
 - Usar squeue para verificar o status dos jobs submetidos.
 - Não esquecer de encerrar alocações interativas.
 - Usar scancel para cancelar jobs.
 - Usar sinfo para ver o status do cluster.
 - Ao usar partições `_shr` lembrem-se de usar `--gres=gpu:<NUM_GPUS>`.

 ___

 ## Tabelinha de comandos essenciais

Comandos Slurm (Sem risco):<br>
 `srun` significa: "rode esse comando no cluster"<br>
 `sbatch` significa "coloque esse script na fila de execução"<br>
 `squeue` vê a lista de jobs em execução<br>
 `scancel` cancela a execução de um job - precisa do job ID<br>
 <br>

Comandos Terminal (Sem risco):<br>
  `cd`, `cp`, `ls`, `pwd`,

Comandos Terminal (Pouco risco, reversível):<br>
  `mv`, `chmod`

Comandos Terminal (Muito risco , irreversível, tem que tomar cuidado):<br>
  `rm`

Comandos Git (sem risco):<br>
 `git clone`

Sobre "riscos": 
 - Não tem como você danificar o cluster ou alguma parte dele permanentemente. No pior dos casos você dará um tiro no próprio pé.
 - Não tem como você apagar ou destruir arquivos dos seus colegas, a não ser que lhe for dado explicitamente permissão de arquivos para isso (via `chmod`).
 - O uso do vscode sem controle na `phocus4` pode deixar ela muito devagar (vscode é muito guloso de recursos e desrespeitoso com outros processos em máquinas compartilhadas), mas isso não é suficiente para danificar ela. No pior dos casos, sua conexão do vscode poderá ser fechada forçosamente pelo cluster.
 - Qual o maior risco que você pode correr? Perder algum arquivo seu por ter apagado ele.



