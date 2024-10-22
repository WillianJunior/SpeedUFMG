# Acessando o cluster

Acesso ao cluster é somente feito via ssh. Recomenda-se usar o sistema Linux para acessar o mesmo por facilidade de uso e tendo em vista que toda documentação foi testada apenas em ambiente Linux. Para ter acesso ao cluster é necessário primeiro logar na máquina externa mica ([login.dcc.ufmg.br]()). Em seguida é possível logar na máquina interna do Speed cerberus ([cerberus.speed.dcc.ufmg.br]()). A cerberus é somente acessível via mica. Na máquina cerberus não existe nenhum serviço para usuários, por isso **não deve ser usada para mais nada além de acessar o cluster**. Por fim, deve-se logar em um nó de login (phocus4). Existem DNSs nas máquinas que reconhecem os hostnames mencionados. O cluster só é acessível do nó de login phocus4, sendo necessário logar-se nele para realizar qualquer tarefa.

O cluster está em uma rede interna da UFMG sem acesso direto à internet. Para ser acessado, é necessário passar pela máquina com acesso externo do CRC (mica). Para ganhar acesso a ela é preciso uma conta gerada pelo CRC vinculada ao grupo *speed*. Isso pode ser feito enviando um email do seu orientador para eles, solicitando acesso. Após geração dessa conta (conseguindo conectar à máquina mica, ver abaixo) deve ser pedido acesso à máquina cerberus no tópico *Novos Acessos* do grupo do telegram. Ao ser gerado o acesso na cerberus, o username para todas as máquinas será o mesmo que o gerado pelo CRC. A senha, porém, será diferente **apenas na cererus**. A senha inicial gerada na cerberus está disponível no tópico *Novos Acessos* do grupo do telegram. Você deverá mudar essa senha no primeiro acesso à cerberus usando o comando 'yppasswd'.

**SEMPRE use a phocus4!!! NÃO se deve trabalhar da cerberus, apenas usá-la para acessar a phocus4!!!**

## Usando ssh pela primeira vez

Por meio do protocolo ssh é possível abrir uma conexão segura com uma máquina externa, retornando um terminal de comandos. Para usuários de Linux, a grande maioria de distribuições já são disponibilizadas com um cliente ssh, porém se não for o seu caso, basta instalar qualquer cliente ssh (recomenda-se openssh-client). Para acessar uma máquina remota basta o comando:

```console
user@host:~$ ssh username@login.dcc.ufmg.br
(username@login.dcc.ufmg.br) Password:
FreeBSD 11.2-RELEASE-p14 (GENERIC) #0: Mon Aug 19 22:38:50 UTC 2019

Welcome to LOGIN.dcc.ufmg.br!

################################################  
#                                              #
#    UNIVERSIDADE  FEDERAL  DE  MINAS  GERAIS  #
#     Departamento de Ciencia da Computacao    #
#                                              #
################################################

### OBS: Utilizar o diretorio /var/tmp para  ###
###      armazenamento temporario.           ###

Bem vindo!

[username@mica ~]$
```

Ao fazer isso será pedida a senha do seu usuário CRC (username). Na primeira vez que você loga em uma maquina nova, o ssh poderá te perguntar se a máquina que está logando realmente é a que você quer (ip e chave ECDSA não reais):

```console
The authenticity of host 'node (192.164.99.99)' can't be established.
ECDSA key fingerprint is 00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff.
Are you sure you want to continue connecting (yes/no)? 
```

Ao aceitar logar em node, a chave deste é salva. Caso o ssh tente se conectar novamente no mesmo nó e a chave for diferente, isso significa que você está logando em uma máquina diferente da que havia logado inicialmente, o que pode ser um problema de segurança. É necessário aceitar uma chave para concluir o login. A partir da mica, deve-se logar na cerberus:

```console
[username@mica ~]$ ssh cerberus.speed.dcc.ufmg.br
username@cerberus.speed.dcc.ufmg.br's password: 
Welcome to Ubuntu ....
username@cerberus:~$ 
```

Por meio do sistema LDAP todos os logins em máquinas do Speed, seja mica, phocus4, ou nós de computação, usam as mesmas credenciais do CRC. A cerberus é a exceção (ler segundo parágrafo deste texto). Assim, quando pedida a senha, basta usar a mesma usada no login mica. Diferentemente da mica, não é necessário especificar seu username já estando na mica. Ele sera inferido como o username usado para logar na mica. Não tem diferença colocar ou omitir seu username a partir daqui.

O último passo é logar na phocus4:

```console
username@cerberus:~$ ssh phocus4
username@phocus4's password: 
username@phocus4:~$ 
```

Na phocus4 você poderá usar o cluster normalmente. Para fechar a conexão remota basta usar o comando exit, ou pelo atalho Ctrl+D.

## Login por chave pública

Como você pode ter percebido, precisar passar por 3 logins é um processo chato. Porém é possível fazer o loging direto com apenas 1 comando ssh e sem precisar colocar senha. Existem duas forma de se logar em uma máquina remota via ssh: (i) verificação de senha, ou (ii) verificação de chaves. O ssh usa um modelo de comunicação criptografada asimétrica. Nele existem duas chaves, uma publica e uma privada. Entregando sua chave publica para alguém (por um canal seguro, como a própia conexão feita com senha), é possivel que essa pessoa verifique que você realmente é quem diz ao submeter sua chave privada em seguida (feito automaticamente pelo seu cliente ssh). Em termos práticos, se dermos nossa chave pública para um nó como a mica, ela poderá saber que você realmente é quem diz ser. 

Caso seja sua primeira vez enviando uma chave pública, é necessário antes a geração dessas de sua máquina privada. Não é preciso usar configurações especiais, apenas apertando enter nos pedidos de input:

```console
user@host:~$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/id_rsa
Your public key has been saved in /home/user/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:80ifYzToRzC+gjJ7%zgtHPT3!uaCUILn3hjUmtm5ffU user@host
The key's randomart image is:
+---[RSA 3072]----+
|  .              |
| . =  .          |
|..=              |
|o+0o. o.         |
| *.+o..oS        |
|. *.a.o*.E .     |
| o.O oo== +      |
|o   =.+.=.       |
|.=   ..*.        |
+----[SHA256]-----+
```

Agora foram gerados 2 aqruivos em /home/user/.ssh: id_rsa e id_rsa.pub, sendo o segundo a sua chave pública. Para fazer o acesso via chave pública, basta colocar o conteudo inteiro de id_rsa.pub em um arquivo authorized_keys na máquina remota:

```console
user@host:~$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABADABagQCdubTA8bEGNHaP4zPevSPHbjkYnCMX5dOfxYvd44yr8e8/O26VEJIuMNzpsVkxW+A4sSEBvSz2wbezT7YcZ5zRy/jEBRrnC4D2qUBCsJ5nyKeaIAE9dqwJoemgfu+1P0Ddv2qYZTECGsu0aA8I1TqFcAqFWbktWqV872/62vncO5VWxLulzGgFg16qNxuUKTGJpD3BMi5DN/7Mxgcgpu9BAOUksxVEbY9KcAvSWVmzGmySKno3USRwXmJQNi9dSo1zHaoPTSLgtzYEh9cm87VdZNVMvLDGoGXT7Jq9gj0thIrYR2gLEY19Xrvdy9aDHsX6JiNSDsWikcyt5XNLYH55BMubNn/+2Kjsl6/PY/VPJa71++FTWnQyvXE6QKXcuPoRywDpBJ8qDNAowTngfV1hkVi+axQBTxRfB7b7jH78FQnu42qjRejgl6ot0H+mriktu13çmRMJC7BGek1QJlaUzxKGVcg++VPgbnBT4CBA9bsWE6+gEcztk= user@host
user@host:~$ ssh username@login.dcc.ufmg.br
(username@login.dcc.ufmg.br) Password:
FreeBSD 11.2-RELEASE-p14 (GENERIC) #0: Mon Aug 19 22:38:50 UTC 2019 ....
[username@mica ~]$ mkdir ~/.ssh
[username@mica ~]$ vim ~/.ssh/authorized_keys
... colar a chave pública, digitar ":wq" + Enter para sair
[username@mica ~]$ chmod 644 ~/.ssh/authorized_keys
[username@mica ~]$
```

Note o 'chmod 644' ao fim da configuração. Se não alterar a permissão de 'authorized_keys' é possível que as chaves públicas neste arquivo sejam ignoradas.

Para testar se o login com chave pública está funcionado basta desconectar da máquina remota e tentar a conexão novamente. Desta vez, não será pedida senha. Isso deve ser feito em todas as máquinas (mica, cerberus e phocus4) usando a mesma chave pública de seu computador pessoal.

## Login por chave pública e tunneling

Porém, o acima só resolve a parte de pedir senha. Ainda são necessários 3 comandos de ssh para acessar a máquina de login (phocus4). Esse processo pode ser automatizado por um tunneling ssh. Existe a possibilidade de criar um arquivo de configuração que descreve como deve ser feita a conexão com uma máquina remota via ssh. Coisas como o ip ou hostname, usuário de login, local da chave pública, porta a ser usada, entre outras. Esse arquivo se encontra em ~/.ssh/config, podendo não existir inicialmente. Se for o caso, basta criá-lo para o usar, não sendo necessário nenhum outro tipo de configuração. Abaixo vem um exemplo de um arquivo config de ssh para acessar todas as máquinas remotas já mencionadas (basta copiar isso no arquivo config de sua máquina pessoal substituindo o username):

```
Host mica
  Hostname login.dcc.ufmg.br
  User username

Host cerberus
  Hostname cerberus.speed.dcc.ufmg.br
  User username
  ProxyCommand ssh mica -W %h:%p
  IdentityFile ~/.ssh/id_rsa
  PubkeyAcceptedKeyTypes +ssh-rsa

Host phocus4
  ProxyCommand ssh cerberus -W %h:%p
  User username
```

No script acima está descrito que: para se conectar à phocus4 com um usuário username é necessário fazer um tunelamento via cerberus. Para se conectar à cerberus é necessário o tunelamento via mica. E a conexão via vica é feita simplesmente por username. Dessa forma, ao rodar o comando 'ssh phocus4', todo esse processo será automatizado. O script acima deve estar presente na sua máquina pessoal, não sendo necessário colocá-lo em outra máquinas. Abaixo o resultado após a criação do arquivo de configuração:

```console
user@host:~$ ssh phocus4
Last login: Sat Mar  2 06:37:21 2024 from 192.168.99.100
user@phocus4:~$
```

Dado que são feitas 3 conexões ssh, é possível que o tempo de login seja um pouco maior (alguns segundos). Quando for usar scp para copiar arquivos para o storage do cluster, isso pode ser feito diretamente via os hostnames que configuramos (e.g., phocus4). Por fim, é possível fazer esse processo de configuração para várias máquinas (caso você tenha mais de um computador), bastando apenas colocar todas as chaves públicas em authorized_keys. Porém é importante ter cuidado ao permitir várias máquinas fazerem login pela sua conta via chave pública. Qualquer um com acesso a uma chave privada poderá se logar pelo seu usuário. Como acessos e comandos executados são armazenados, estes podem ser auditados para encontrar responsaveis de possíveis abusos ou mal usos do cluster.

## TLDR
 - Acesso ao cluster somente via ssh
 - Mais fácil em sistemas Linux
 - O que você deve fazer, em ordem, um passo de cada vez, para acessar pela primeira vez o cluster:
   1. Criar uma conta no CRC especificando que precisa estar no grupo 'speed'
   2. Pedir a criação de uma conta na cerberus no tópico 'Novos Acessos' do grupo do telegram
   3. Criar um par de chaves ssh na sua máquina via 'ssh-keygen', caso você não tenha chaves ssh no seu pc
   4. Criar o arquivo ~/.ssh/config descrito acima
   5. Rodar o comando 'ssh phocus4'
   6. Resolvido
 - Configure chave pública para acesso mais fácil ao cluster, assim não será necessário colocar a sua senha 3 vezes.


