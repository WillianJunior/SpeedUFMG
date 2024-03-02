# FAQ

Perguntas respondidas mais frequentes. Já sabendo usar mais ou menos o cluster e tendo problemas, a primeira coisa que deve ser feita é ler esse FAQ. Como uma "diversão", cada pergunta tem um contador de quantas vezes alguem teve essa dúvida e perguntou no grupo antes de ler esse FAQ. Eu tenho plena confiança que vocês, eximios usuários, farão o possível para deixar esses contadores zerados.

## [2] Meus códigos/dados estão em uma gorgona e não consigo mais acessá-los. O que eu faço para acessá-los?
Basta submeter um job interativo. Ao receber a alocação você terá uma sessão interativa com acesso à gorgona de sua escolha. Nessa sessão você poderá acessar os dados locais do nó alocado.

## [1] Eu não consigo acessar meus arquivos em /home_cerberus/speed/username, não tendo permissão. O diretório, assim como os arquivos aparecem com outro owner. O que devo fazer?
 - Isso está sendo um problema recorrente da forma como a home_cerberus é montada em todos nós (sshfs). Isso é causado pela interação do sshfs com LDAP.
 - Para resolver, basta alguém com acesso root usar o chown -R para corrigir a propriedade do diretório, assim como dos arquivos.
 - Essa solução é dependente de nó. Isso significa que ao fazer isso em uma gorgona1, por exemplo, **você não terá acesso em uma gorgona2!**
 - Estamos abertos a sugestões de soluções paliativas, porém, isso será resolvido permanentemente com o sistema Lustre.
 - Outra solução paliativa é usar o storage local para manter os seus dados quando houver instabilidades nesse acesso.

## [2] O module python3.12.1 não está carregando, mostrando apenas o python3.10.
 - Tente carregar, descarregar e carregar o python3.12.1 algumas vezes até funcionar:

```command
username@phocus4:~$ python3 --version
Python 3.10.12
username@phocus4:~$ module load python3.12.1
Python 3.10.12
username@phocus4:~$ module unload python3.12.1
username@phocus4:~$ module load python3.12.1
username@phocus4:~$ python3 --version
Python 3.12.1
```

## [1] Não estou conseguindo mais criar um venv na home_cerberus.
 - A máquina cerberus está instável, falhando ocasionalmente.
 - Arquivos ainda estão acessíveis na home_cerberus, porém foram identificados problemas ao gerar (ou mover) venv’s para ela.
 - Quando você tiver problemas relacionados à cerberus, busque soluções para usar ela o menos possível.
 - Exemplo, crie seu venv na gorgona que você quiser usar:

```command
username@phocus4:/root$ srun -w gorgona7 --time 10:00:00 --pty bash
username@gorgona7:/root$ cd ~
username@gorgona7:~$ pwd
/home/pos/username
username@gorgona7:~$ ls
username@gorgona7:~$ module avail
---------------------- /opt/Modules/modulefiles ----------------------
anaconda3.2023.09-0  module-git   modules  python3.12.1  
dot                  module-info  null     use.own       

Key:
modulepath  
username@gorgona7:~$ module load python3.12.1
username@gorgona7:~$ python3 --version
Python 3.12.1
username@gorgona7:~$ python3 -m venv g7venv
username@gorgona7:~$ source g7venv/bin/activate
(g7venv) username@gorgona7:~$ python3 --version
Python 3.12.1
```
 - Uma desvantágem dessa solução é que você deverá usar apenas uma gorgona para seus testes por venv. Alternativamente, você pode criar um venv local em cada gorgona que usar.

## [1] A minha home não existe em algumas gorgonas.
As gorgonas foram formatadas e preparadas em momentos diferentes, então por mais que a gente tente mantê-las consistentes entre si, não tem como fazer isso de forma mais definitiva até uma formatação completa delas. Essa formatação é algo a ser feito mais a frente.

Uma dessas diferenças encontradas foi o path da home '~'. As vezes este é localizado em /home/vip/username e às vezes /home/pos/username. A única forma atual de resolver problemas dos seus scripts é nos seus scripts. Infelizmente é necessário encontrar alguma solução programatica para isso (e.g., fazer um if path exists no batch script).
