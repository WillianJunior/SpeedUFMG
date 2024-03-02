# Acessando o cluster

O cluster está em uma rede interna da UFMG sem acesso direto à internet. Para ser acessado, é necessaŕio passar pela máquina com acesso externo do CRC. Para ganhar acesso a ela é preciso uma conta pelo CRC, que pode ser feito enviando um email do seu orientador para eles, solicitando acesso.

Acesso ao cluster é somente feito via ssh. Recomenda-se usar o sistema Linux para acessar o mesmo por facilidade de uso. Para ter acesso ao cluster é necessário primeiro logar na máquina externa mica ([login.dcc.ufmg.br]()). Em seguida é possível logar na máquina interna do Speed cerberus ([cerberus.speed.dcc.ufmg.br]()). A cerberus é somente acessível via mica. Na máquina cerberus não existe nenhum serviço para usuários. Por fim, deve-se logar em um nó de login (phocus4). Existem DNSs nas máquinas que reconhecem os hostnames mencionados.

## Usando ssh pela primeira vez

Por meio do protocolo ssh é possível abrir uma conexão segura com uma máquina externa, retornando um terminal de comandos. Para usuários de Linux, a grande maioria de dists Linux já são disponibilizadas com um cliente ssh, porém se não for o seu caso, basta instalar qualquer cliente ssh (recomenda-se openssh-client). Para acessar uma máquina remota basta o comando:

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
Ao fazer isso será pedida a senha do seu usuário CRC (username). Na primeira vez que você loga em uma maquina nova, o ssh poderá te perguntar se a máquina que está logando realmente é a que você quer:

```console
The authenticity of host 'node (192.164.99.99)' can't be established.
ECDSA key fingerprint is 00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd:ee:ff.
Are you sure you want to continue connecting (yes/no)? 
```

Ao aceitar logar em node, a chave deste é salva. Caso o ssh tente se conectar em node e a chave for diferente, isso significa que você está logando em uma máquina diferente da que havia logado inicialmente, o que pode ser um problema de segurança. É necessário aceitar uma chave para concluir o login. A partir da mica, deve-se logar na cerberus:

```console
[username@mica ~]$ ssh cerberus.speed.dcc.ufmg.br
username@cerberus.speed.dcc.ufmg.br's password: 
Welcome to Ubuntu ....
username@cerberus:~$ 
```

Por meio do sistema LDAP todos os logins em máquinas do Speed, seja mica, cerberus ou phocus4, usam as mesmas credenciais do CRC. Assim, quando pedida a senha, basta usar a mesma usada no login mica. Diferentemente da mica, não é necessário especificar seu username já estando na mica. Ele sera inferido como o username usado para logar na mica. Não tem diferença colocar ou omitir seu username a partir daqui.

O último passo é logar na phocus4:

```console
username@cerberus:~$ ssh phocus4
username@phocus4's password: 
username@phocus4:~$ 
```

Na phocus4 você poderá usar o cluster normalmente. Para fechar a conexão remota basta usar o comando exit, ou pelo atalho Ctrl+D.

## Login por chave pública e tunneling

Como você pode ter percebido, precisar passar por 3 logins é um processo chato. Porém é possível fazer o loging direto com apenas 1 comando ssh e sem precisar colocar senha. Existem duas forma de se logar em uma máquina remota via ssh: (i) verificação de senha, ou (ii) verificação de chaves. O ssh usa um modelo de comunicação criptografada asimétrica. Nele existem duas chaves, uma publica e uma privada. Entregando sua chave publica para alguém, é possivel que essa pessoa verifique que você realmente é quem diz ao submeter sua chave privada em seguida. Em termos práticos, se dermos nossa chave pública para um nó como a mica, basta o ssh enviar secretamente a sua chave privada, sendo possível verificar que você é o dono da sua chave pública anteriormente enviada. 

Caso seja sua primeira vez enviando sua chave pública, é necessário antes a geração dessas de sua máquina privada. Não é preciso usar configurações especiais, apenas apertando enter nos pedidos de input:

```console
user@host:~$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa):
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/.ssh/id_rsa
Your public key has been saved in /home/user/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:80ifYuToRzC+gjJ70zgtHPT30uaCUILnNhjUmtm2ffQ user@host
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

Agora foram gerados 2 aqruivos em /home/user/.ssh: id_rsa e id_rsa.pub, sendo o segundo a sua chave pública. Para fazer o acesso via chave pública, basta colocar o conteudo inteiro de id_rsa.pub em um arquivo authorize_keys na máquina remota:

```console
user@host:~$ cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABagQCTubTA8bEGNHvP4zPevSPHbYkYnCMX5dO6xYvd4Eyr8e8/O2KVEJIuNNzzsVkxW+A4sSEBvSz2wbezT7YcZ5zRy/jEBurnC4D2qUBCsJ5nyKeaIAE9dqwJoemgfu+1P0Ddv2qYZTECGsu0aA8I1TqFcAqFWbktWqV872/62vncO5VWxLulzGgFg16qNxuUKTuJpD3BMi5DN/7Mxgcgpu9BAOUksxVEbY9KcAvSWVmzGmySKno3USRwXmJQNi9dSo1zHaoPTSLgtzYEh9cm87VdZNVMvLDqoGXT7Jq9gj0thIrYR2gLEY19Xrvdy9aDHsX6JiNSDsWikcyt1XNLYHm5BMubNn/+2Kjsl6/PY/VPJa71++FTWnQyvXE6QKXcuPoRywDpBJ8qDNAowTngfV1hkVi+axQBTxRfB7b7jH78FQnu42qjRejgl7ot0H+mriktu13çmRMJC7BGek1QJlaUzxKGVcg++VPgbnBT4CBA9bsWE6+gEcztk= user@host
user@host:~$ ssh username@login.dcc.ufmg.br
(username@login.dcc.ufmg.br) Password:
FreeBSD 11.2-RELEASE-p14 (GENERIC) #0: Mon Aug 19 22:38:50 UTC 2019 ....
[username@mica ~]$ mkdir ~/.ssh
[username@mica ~]$ vim ~/.ssh/authorized_keys
... colar a chave pública, :wq
[username@mica ~]$
```

Para testar se o login com chave pública está funcionado basta desconectar da máquina remota e tentar a conexão novamente. Desta vez, não será pedida senha. Isso deve ser feito em todas as máquinas (mica, cerberus e phocus4).

Porém, isso só resolve a parte de pedir senha. Ainda são necessários 3 comandos de ssh para acessar a máquina de login (phocus4). Esse processo pode ser automatizado por um tunneling ssh. Existe a possibilidade de criar um arquivo de configuração que descreve como deve ser feita a conexão com uma máquina remota via ssh. Coisas como o ip ou hostname, usuário de login, local da chave pública, porta a ser usada, entre outras. Esse arquivo se encontra em ~/.ssh/config, podendo não existir inicialmente. Se for o caso, basta criá-lo para o usar, não sendo necessário nenhum outro tipo de configuração. Abaixo vem um exemplo de um arquivo config de ssh para acessar todas as máquinas remotas já mencionadas:

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

No script acima temos que para se conectar à phocus4 com para um usuário username é necessário fazer um tunelamento via cerberus. Para se conectar à cerberus é necessário o tunelamento via mica. E a conexão via vica é feita simplesmente por username. O script acima deve estar presente na sua máquina pessoal, não sendo necessário colocá-lo em outra máquinas. Abaixo o resultado após a criação do arquivo de conf:

```console
user@host:~$ ssh phocus4
Last login: Sat Mar  2 06:37:21 2024 from 192.168.99.100
user@phocus4:~# 
```

Dado que são feitas 3 conexões ssh, é possível que o tempo de login seja um pouco maior (alguns segundos). Quando for usar scp para copiar arquivos para o storage do cluster, isso pode ser feito diretamente via os hostnames descritos em conf. Por fim, é possível fazer esse processo de configuração para várias máquinas (caso você tenha mais de um computador), bastando apenas colocar todas as chaves públicas em authorized_keys. Porém é importante ter cuidado ao permitir várias máquinas fazerem login pela sua conta via chave pública. Qualquer um com acesso à uma chave privada poderá se logar pelo seu usuário. Como acessos e comandos executados são armazenados, estes podem ser auditados para encontrar responsaveis de possíveis abusos ou mal usos do cluster.

## TLDR
 - Acesso ao cluster somente via ssh
 - Mais fácil em sistemas Linux
 - Necessária conta do CRC
 - A máquina inicial do cluster é a phocus4, acessivel via mica->cerberus->phocus4
 - Veja acima como usar chave pública e tunneling para acesso mais fácil ao cluster


