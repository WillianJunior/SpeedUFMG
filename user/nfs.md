# Sistema de arquivos NFS (TRIAL)

**NOTA: o sistema snfs1 está em fase de testes. Assumam que seus arquivos nele possam ser perdidos. Havendo problemas notifiquem no grupo do Telegram para melhorarmos o uso dele :)**

Foi implementado um sistema NFS para storage compartilhado entre as máquinas do Sonic. Ele foi montado em todas as máquinas no path /snfs1. Em /snfs1 existe o dir /snfs1/speed. Em /snfs1/speed não é possível criar arquivos comuns, porém pode-se criar um dir pessoal para você usar, e neste dir usar seus arquivos normalmente. O snfs1 é equivalente às outras soluções de storage do Sonic, exceto que **venvs funcionam nele**. É possível criar uma venv em snfs1 em uma máquina (gorgona3 por exemplo) e carregar o mesmo venv em outra (gorgona10 por exemplo).

Outra diferênça é o desempenho. Aṕos benchmarks preliminares vimos que ele tem desempenho fraco para carregamento de arquivos pequenos (NFS usa comunicação via RPC e é bem verboso). Isso pode ser uma questão (i) do HD usado no host servidor, (ii) do desempenho de I/O e CPU/Mem do servidor, (iii) uma questão de rede, ou (iv) uma questão de má configuração da nossa parte. Então, fiquem atentos ao desempenho de I/O e notifiquem no Telegram problemas ou insights.

## Quotas

O snfs1 foi montado com cotas em mente. Isso significa que será possível limitar o uso de storage de usuários a nível de projetos. Atualmente **não tem limite**, porém estamos no processo de teste de sistemas de cotas.

### Como funciona:
Cotas em sistemas Linux (quotas) podem limitar o número de arquivos (inodes) ou blocos (tamanho total de arquivos) a nível de usuário, grupos (e.g., speed) ou projetos. Esses limites possuem 2 thresholds: soft e hard limit. O hard limit não permite que um usuário passe dele de forma alguma. Já o soft, permite que ele seja passado por um periodo de tempo (grace time). Após o grace time, qualquer requisição de alocação de storage será barrada até que o uso de storage reduza para menos que o soft limit.

Exemplo: Temos um hard limit de 10G, um soft limit de 5G e um grace time de 1 semana. 
 - Começo a trabalhar usando 4G de storage. Resultado: nada acontece. Porém tenho um limite "teorico" de 10G de espaço para usar
 - Nos trabalhos chego a usar 7G. Resultado: consigo usar os 7G, porém meu grace time começa a contar
 - Grace time vence. Resultado: não consigo mais criar novos arquivos ou pedir mais espaço (Out of space error)
 - Apago 5G de dados, tendo agora só 2G de dados. Resultado: Assim que meu uso cair de 5G terei "em teoria" 10G de limite novamente.

### Sobre usuários, grupos e projetos:
Limites diferentes podem ser aplicados a usuários ou grupos de forma individual. Também é possível criar uma entidade de grão mais fino chamada projeto. Em snfs1 **apenas quotas de projeto serão usadas**. Atualmente existe apenas 1 projeto (speed) que todos podem usar. Para evitar que o storage fique cheio ao ponto de inviabilizar o seu uso por outros usuários, também será possível realizar alocações de projetos. Aqueles que começarem a usar o snfs1 e se sentirem confortaveis com ele poderão pedir a criação de um projeto no tópico "Novos Acessos" no Telegram. Será feita uma alocação exclusiva para o projeto, sendo possível criar um grupo unix a fim de permitir apenas que usuários deste grupo acessem esse projeto.

### Qual é o meu uso?
Existem ferramentas para verificação de quotas e quanto dela você está usando. Porém, para as tecnologias usadas para implementar o snfs1 (xfs por NFS) não é possível ainda verificar uso de quotas remotamente (como pela phocus4). Isso é algo que está em desenvolvimento e será implementado no futuro. Porém é possível verificar o uso global via df:

```command
username@phocus4:~$ df -h
Filesystem                          Size  Used Avail Use% Mounted on
tmpfs                               1.6G  2.3M  1.6G   1% /run
/dev/sda2                            94G   29G   61G  32% /
tmpfs                               7.9G     0  7.9G   0% /dev/shm
tmpfs                               5.0M     0  5.0M   0% /run/lock
efivarfs                             72K   39K   29K  58% /sys/firmware/efi/efivars
/dev/sda1                           476M  6.1M  469M   2% /boot/efi
/dev/sda4                           1.7T  557G  1.1T  35% /home
cerberus:/home                      826G  774G   11G  99% /home_cerberus
150.164.203.121:/nfs/exports/snfs1  2.0T   15G  2.0T   1% /snfs1
```

Como visto, são 2TB de storage inicial, com mais storage a ser adicionado no futuro.

## Usando envs eficientemente

Usar um venv ou conda env diretamente no NFS é muito devagar (explicação do porque isso acontece mais abaixo). Porém, temos como reduzir o tempo de minutos para menos de 5 segundos para a criação e instalação de libs e outras dependências. Como? Fazendo criação/instalação local e copiando um zip para o NFS. O processo a seguir é o messmo venv ou conda env, então vamos só falar só do venv daqui pra frente. Primeiramente, a partir da phocus4 é criado o venv e instalado as dependências:

```command
username@phocus4:~$ cd /tmp
username@phocus4:/tmp$ module load python3.12.1
username@phocus4:/tmp$ python3 -m venv /tmp/new-venv
username@phocus4:/tmp$ source /tmp/new-venv/bin/activate
(new-venv) username@phocus4:/tmp$ pip3 install numpy
Collecting numpy
  Obtaining dependency information for numpy from https://files.pythonhosted.org/packages/8c/3d/1e1db36cfd41f895d266b103df00ca5b3cbe965184df824dec5c08c6b803/numpy-2.2.6-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata
  Using cached numpy-2.2.6-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (62 kB)
Using cached numpy-2.2.6-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (16.5 MB)
Installing collected packages: numpy
Successfully installed numpy-2.2.6
(new-venv) username@phocus4:/tmp$ 
```

Note que estamos criando o venv em /tmp, um diretório que deve estar montado localmente em qualquer máquina. Em seguida é zipado o venv gerado e movido para /snfs1 (note o tempo de execução de 8s):

```command
(new-venv) username@phocus4:/tmp$ zip -r new-venv.zip new-venv/
  adding: new-venv/ (stored 0%)
  adding: new-venv/pyvenv.cfg (deflated 41%)
  adding: new-venv/lib/ (stored 0%)
  adding: new-venv/lib/python3.12/ (stored 0%)
  [...]
  adding: new-venv/lib64/python3.12/site-packages/numpy/fft/_helper.pyi (deflated 72%)
  adding: new-venv/include/ (stored 0%)
  adding: new-venv/include/python3.12/ (stored 0%)
(new-venv) username@phocus4:/tmp$ time mv new-venv.zip /snfs1/speed/username/

real  0m8,941s
user  0m0,002s
sys   0m0,175s
```

Para usar o venv, basta fazer o processo contrário, copiar de /snfs1 para seu /tmp e deszipar (note que leituras no NFS são mais rápidas) (também note que o unzip é rápido):

```command
username@gorgona3:~$ time cp /snfs1/speed/username/new-venv.zip /tmp

real	0m0.514s
user	0m0.000s
sys	0m0.143s
username@gorgona3:~$ cd /tmp/
username@gorgona3:/tmp$ time unzip new-venv.zip 
Archive:  new-venv.zip
   creating: new-venv/
  inflating: new-venv/pyvenv.cfg    
  [...]
   creating: new-venv/include/
   creating: new-venv/include/python3.12/


real	0m1.516s
user	0m1.119s
sys	0m0.396s
username@gorgona3:/tmp$ source /tmp/new-venv/bin/activate
(new-venv) username@gorgona3:/tmp$ python3
Python 3.12.1 (tags/v3.12.1:2305ca5144, Jan 26 2024, 17:20:29) [GCC 11.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy as np
>>> 
```
Acima foi feito o teste de importar o numpy que havia sido instalado pela phocus4. Mas e se eu precisar instalar mais outro pacote? Faça o mesmo processo acima, carregando no /tmp da phocus4, instalando o pacote que deseja, zipando e movendo para /snfs1. Como o caso de uso mais comum é o de ativar o venv e rodar seus testes, esse processo de re-zipar deverá ser raramente realizado.

### Explicação do problema

Embora o /snfs1 consiga ser consistente em todos os nós, permitindo a criação de um venv em um nó e o seu uso em outro, essas operações são bem demoradas. Exemplo, para criar um venv em phocus4:/snfs1/speed demora cerca de 3-4 minutos! Para instalar um numpy nesse venv mais 2-3 minutos!!! Isso é uma característica de realizar operações pela rede. Para a criação de um arquivo f.txt de 1 byte em um path /snfs1/speed/a/b/f.txt são feitas as sequintes chamadas RPC (assumindo que estamos em /snfs1/speed):
```
client -> server: Tenho permissão para acessar /snfs1/speed/a ?
server -> client: Sim
client -> server: Mude o diretório corrente para /snfs1/speed/a
server -> client: Ok
client -> server: Tenho permissão para acessar /snfs1/speed/b ?
server -> client: Sim
client -> server: Mude o diretório corrente para /snfs1/speed/a/b
server -> client: Ok
client -> server: Me passe info de permissão para o dir /snfs1/speed/a/b
server -> client: /snfs1/speed/a/b com permissões rwxrwxr-x
client -> server: Crie e abra o arquivo /snfs1/speed/a/b/f.txt
server -> client: Ok
client -> server: Escrita em /snfs1/speed/a/b/f.txt ...
[...]
client -> server: Feche o arquivo /snfs1/speed/a/b/f.txt
server -> client: Ok
```

Como visto, são necessárias várias trocas de mensagens pela rede até conseguir abrir um arquivo. A rede pode ser de alta velocidade, mas a latência está presente em todas as mensagens. Dado que um venv com apenas um numpy tem mais de 2000 arquivos e ocupa apenas uns 80MB, usar venvs (seja criar, ativar, instalar, usar pacotes) é uma operação que trabalha com muitos arquivos pequenos. Esse é o pior caso para um storage em rede. Mas por que então usamos um NFS? Precisamos de um storage compartilhado entre todas as máquinas, que seja acessível do nó de login.










