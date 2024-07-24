# Soluções Paliativas

Roma não foi construída em um dia, e nem o nosso cluster. Ele é o resultado de melhorias incrementais, o que significa que existem vários problemas ou chatices para lidarmos. Neste texto são levantados alguns problemas recorrentes pelo sistema estar em montagem. Problemas esses onde podemos usar de soluções paliativas para conseguir usar o cluster do jeito que está enquanto uma solução permanente está em implementação.

## 1. Storage
Atualmente não existe uma solução de DFS disponível no cluster. Ela será o lustre (já em estado de implementação). Porém é necessário haver um ambiente de acesso a arquivos consistênte entre todas as máquinas. No momento isso é implementado via o 'sshfs' do drive home_cerberus em todas as máquinas, o que embora seja uma solução inicial eficaz, não é muito eficiente.

### Problema 1.1. Espaço
A home_cerberus está em um drive de 1TB, o que não é muita coisa para vários usuários com dados grandes e 8 máquinas disponíveis para execução. Para mitigar problemas de espaço (já tivemos 100% da home_cerberus ocupada, atualmente nunca caindo de 70%) é possível manter seus dados maiores em um outro drive no nó cerberus. Ele conta com mais dois drives de 4TB cada: cerberus:/dev/sdb1 montado em  cerberus:/home/disk2 e cerberus:/dev/sdc1 montado em cerberus:/home/disk3, na cerberus. Pede-se então que usem os drives de 4TB para armazenamento de dados maiores, já que eles também são acessiveis via phocus4:/home_cerberus/disk2 e phocus4:/home_cerberus/disk3 (phcous4 ou gorgonas). Isso foi feito permitindo symlinks serem seguidos via 'sshfs'. Também é pedido que a quantidade de dados em phocus4:/home_cerberus/speed/username seja mínima (tentem não exceder 10GB). Para padronizar a localização dos arquivos, é possível gerar um symlink de um disco de 4TB para phocus4:home_cerberus/speed:

```command
username@phocus4:~$ mkdir /home_cerberus/disk3/speed/username2
username@phocus4:~$ ln -s /home/disk3/speed/username2 ./username2-disk3
ln: failed to create symbolic link './anne_disk3': Input/output error
```

Em ambos cerberus:/home/disk2 e cerberus:/home/disk3 existem um diretório speed, onde todos usuários tem permissão de criação de diretórios. **IMPORTANTE: não se deve usar a cerberus para nada além de acessar a phocus4!!! Criar diretórios, copiar arquivos, compilar códigos e submeter experimentos devem ser feitos da phocus4.**

O comando 'ln' acima retorna um erro, porém isso é causado pela discrepância entre os paths na cerberus e na phocus4 (/home e /home_cerberus respectivamente). Por esse motivo o link é feito usando o path da cerberus, mesmo que fazendo isso na phocus4. Embora tenha retornado esse erro, é possível acessar o link criado. Foi verificado também que o comandos 'pwd -P' retorna um valor errado, devendo retornar o path fisico e não o lógico. Outro problema com essa abordagem é o comando 'ls', que demora a atualizar o conteudo real do path acessado pelo link. Isso pode resultar em arquivos sendo gerados mas que não são imediatamente mostrados pelo 'ls'. Porém, ao criar um arquivo via 'touch' e remove-lo via 'rm' a partir do path real (/home_cerberus/disk3/speed/username2), o arquivo consegue ser apagado, sem erros retornados por 'rm'. Caso sejam descobertos problemas a melhor solução seria abandonar links simbolicos e usar o path real em suas aplicações.

### Problema 1.2. Ownership
Já é um problema recorrente, e ainda aberto, a perda de acesso a arquivos devida à uma leitura erronea de ownership. O problema se apresenta quando um arquivo seu, embora acessível (você pode ler e editar) em um nó, como a phocus4, não é mais acessível em outro nó (uma gorgona por exemplo). Isso é bem incomodo quando é necessário fazer o carregamento de um venv e aparentemente você não consegue executar o source.

Solução: tentar usar storage local das gorgonas para arquivos que apresentem esse problema de forma recorrente. Essa não é uma solução muito boa, até porque é necessário manter o arquivo em todos os nós que você quiser usar. Novamente, essa é uma solução paliativa até a chegada do lustre DFS. Existem duas entradas na FAQ que abordam esse tema de [ownership](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/faq.md#1-eu-n%C3%A3o-consigo-acessar-meus-arquivos-em-home_cerberusspeedusername-n%C3%A3o-tendo-permiss%C3%A3o-o-diret%C3%B3rio-assim-como-os-arquivos-aparecem-com-outro-owner-o-que-devo-fazer) e [venv's](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/faq.md#1-n%C3%A3o-estou-conseguindo-mais-criar-um-venv-na-home_cerberus).

## 2. SSH
Embora o slurm permita a configuração do Linux PAM para permitir acesso às maquinas alocadas a quem as alocou, isso ainda não foi configurado no cluster. Dessa forma existe apenas uma maneira de se acessar diretamente um nó de computação (e.g., gorgonas): via [sessão interativa](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/submissao-slurm.md#jobs-interativos).

### Problema 2.1. Copiar dados para as gorgonas
Se não é possível acessar uma gorgona via ssh diretamente, também não é possível realizar um 'scp' direto a elas. Porém, tendo elas acesso à home_cerberus é possível abrir uma sessão interativa em uma gorgona e realizar o 'cp' da home_cerberus para seu storage local. Infelizmente não é tão fácil fazer um 'scp' a partir de uma gorgona para uma máquina externa (fica como exercício ao leitor, ou não...), então para passar dados externos diretamente para uma gorgona é necessário antes passa-lo pela home_cerberus, seja via o nó cerberus ou phocus4. Para transferências muito grandes, que podem ser interrompidas por uma queda de conexão, recomenda-se usar os comandos 'screen' ou 'rsync' em um último caso (ambos com documentação via 'man').

## 3. Uso exclusivo de máquinas
Caso você tenha preparado seu ambiente de testes em uma máquina específica e não queira ficar esperando na fila, basta alocar outro nó. Não existem limites de alocações. Você pode pedir o tempo que for necessário, como mais de 1000 hrs (~1 mês e meio), ou até mais. Se houverem vários jobs que você precise submeter, basta submetê-los. O slurm vai rodar cada um dos seus jobs na ordem que você os submeteu. No pior dos casos vai haver alguem que, assim como você, só configurou os experimentos em um nó. Neste caso, fica a dica de deixar mais de um nó preparado para os seus experimentos. É possível passar uma lista de nós que você precisa que o seu job use (parâmetro -w tanto para 'srun' como para 'sbatch').






