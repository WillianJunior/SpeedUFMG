# Storage

O cluster possui dois tipos de espaço para armazenamento: local e distribuído. Armazenamento local é aquele presente fisicamente em cada nó usado, e é acessível apenas de seu nó. Armazenamento distribuído (DFS) é um espaço acessível globalmente por qualquer máquina no cluster. Pode-se imaginar dados nesse espaço como em um HD gigante conectado a todas as máquinas, ou em um serviço Google Drive ou Dropbox.

## Storage local

Para nós de login, não faz sentido acessar seu armazenamento local já que qualquer dado local no nó de login é acessível somente por ele (nós de computação não conseguem acessar). Para nós de computação o storage local deve ser visto como um espaço temporário, limpo ao fim de cada job. Usar armazenamento local pode ser interessante para otimizar os tempos de acesso a dados, em casos específicos. Porém, vale lembrar que qualquer dado neste espaço de armazenamento é volátil, sendo necessário copiar explicitamente arquivos de interesse nele presentes para o DFS **antes do fim da alocação**. A fim de padronização assuma que qualquer dado que seja deixado no armazenamento local após o fim de uma alocação (seja batch script ou interativa) será **perdido**, podendo ser apagado ou corrompido.

O storage local dos nós de computação está localizado no path '/home/all_home'. Este path é válido em qualquer nó de computação. Neste path todos usuários tem permissão para ler, escrever e criar arquivos. A fim não ficar desorganizado é pedido a qualquer usuário que use esse espaço para criar antes um diretório com seu nome e colocar seus dados neste diretório recém criado. Por exemplo, '/home/all_home/username'. Como acesso ssh direto aos nós de computação é permitido apenas para alicações interativas, não é possível transferir dados via 'scp'. Dessa forma, pode-se copiar arquivos do DFS (que é elaborado mais a frente) para o armazenamento local.

Outro detalhe importante é: assuma que, exceto por '/home/all_home/', nenhum usuário tem acesso a qualquer outro arquivo ou path local dos nós de computação. Por exemplo, um path de sua home '/home/pos/username' não tem acesso liberado ao usuário 'username'.

## Storage distribuído (DFS)

Dados globalmente acessíveis estão disponíveis no diretório ‘/home_cerberus/speed/username’. O diretório ‘/home_cerberus’ é montado em todas as máquinas (login e computação), e qualquer dado nele é visível em todo cluster. Neste ambiente é esperado que código, dados de entrada, resultados, scripts e logs sejam armazenados.

Atualmente o DFS não é distribuído, sendo um diretório da máquina cerberus montada em todos nós do cluster. Futuramente será usado o sistema Lustre para manter esses dados. Caso hajam problemas de acesso, sendo o mais recorrente '/home_cerberus' não estar montado, basta notificar no grupo do Telegram.

### Gerenciando espaço

Uma consequência infeliz do Slurm foi ao aumentar o alcance dos recursos para os alunos agora temos muito mais usuários, e como todos precisam armazenar dados de experimentos isso colocou uma pressão nos recursos de armazenamento. Além disso, o local onde o DFS está montado atualmente (nó crberus) é um nó antigo e com armazenamento limitado para a necessidade de armazenamento do cluster. Na cerberus existem 3 discos fisicos: /home (sda onde está a home_cerberus), /home/disk2 (sdb) e /home/disk3 (sdc):

```console
username@phocus4:/home_cerberus# df -h .
Filesystem      Size  Used Avail Use% Mounted on
cerberus:/home  826G  775G  8,6G  99% /home_cerberus
username@phocus4:/home_cerberus# df -h disk2
Filesystem      Size  Used Avail Use% Mounted on
cerberus:/home  3,6T  2,9T  542G  85% /home_cerberus
username@phocus4:/home_cerberus# df -h disk3
Filesystem      Size  Used Avail Use% Mounted on
cerberus:/home  3,6T  2,0T  1,5T  59% /home_cerberus
```

Um problema atual é que do disco 1 também é usado pelo SO da cerberus. Dessa forma, caso alguém gaste todo o espaço em cerberus:/dev/sda o SO pode travar. Como a cerberus é o nó de entrada para o cluster, é possível que **apenas 1 usuário trave o laboratório inteiro travando a cerberus, e bloqueando o acesso às outras máquinas!!!**. Isso foi algo que já aconteceu, travando o acesso ssh pois não havia espaço para o deamon rodar. Já está sendo implementada uma solução permanente, com um sistema DFS Lustre, mas no meio tempo pedimos a ajuda daqueles que usam o sistema para evitar tais problemas.

Como pode-se observar, os discos 2 e 3 são montados dentro da cerberus:/home (phocus4:/home_cerberus), assim são acessíveis pela home_cerberus de qualquer nó no cluster. Dessa forma, eles são trivialmente acessíveis para aqueles que já usam a home_cerberus. Pedimos que ao copiar dados para o ambiente do cluster sejam tomados os seguintes cuidados:
 1. Preste atenção na quantidade de dados que você está movendo. Verifique se tem espaço no cluster antes (o comando 'df -h PATH' é usável por qualquer usuário).
 2. Priorize usar os discos 2 e 3. Temos documentação de como fazer isso [aqui](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/gamba.md#problema-11-espa%C3%A7o).
 3. Façam tudo na phocus4, não é para ficar mexendo da cerberus!!! As configurações de acesso são testadas todas na phocus4.
 4. PRESTE MUITA ATENÇÃO NOS SEUS DADOS!!! Vamos tentar evitar problemas...

## Performance

Embora incomum, é possível que sua aplicação tenha perda de performance no acesso aos dados do DFS, principalmente se houverem várias operações pequenas de leitura. Para cada operação de leitura existe um overhead significativo pois os dados estão sendo acessados em um ambiente de rede. Uma forma de mitigar esse problema seria implementações que fazem carregamento de dados em bulk, assim amortizando o custo de leitura. Outra alternativa seria o uso do storage local. Porém, não é recomendado se preocupar com isso se não for identificado algum gargalo. Lembre-se, otimização prematura é a raiz de todo mal.

## TLDR
 - Usar principalmente DFS em  /home_cerberus/speed/username.
 - Dados no DFS são globalmente acessíveis por todos os nós do cluster.
 - Storage local pode ser usado, mas apenas quando for justificável (baixa performance de leitura do DFS).




