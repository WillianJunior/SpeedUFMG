# Planejamento de tarefas para recuperação do SPEED

## Infra de rede
 - separar switch
 - formatar máquina HEAD (cerberus2)
   - enteprise linux (rocky8) (necessário para o head do lustre dps)
   - colocar DHCP
   - colocar DNS
   - adicionar à infra do CRC (acesso via mica)
   - incorporar LDAP

## Nó de storage sshfs (tmp)
 - formatar nó tmp
 - adicionar na rede e testar
 - incorporar LDAP

## Definir estrutura
 - onde as máquinas ficarão mais definitivamente?
 - qual painel de energia será usado?
 - qual é o nosso budget de energia e espaço para o cluster?
 - haverão 3 serviços principais: 
   - infra redes
   - slurm
   - lustre
 - haverão 3 nós, além das gorgonas:
   - cerberus2:
     - nó de gestão de serviços
     - deve-se passar por ele para entrar no nó de login
     - ninguem tem acesso para mexer em nada nele, além dos admins
     - DHCP + DNS
     - slurm e lustre HEADs
   - gibraltar1:
     - nó de login
     - acessível via cerberus2
     - todos tem acesso a ela, sem storage local
   - gorgonas[1-10]:
     - nós de computação slurm
   - alexandria1:
     - nó de storage do lustre

## Migrar slurm
 - montar slurm HEAD em cerberus2
 - adicionar novo nó login (com LDAP)
 - mover uma gorgona para a nova rede
   - configurar ips e hostnames
   - configurar ldap
   - configurar slurm
 - mover o resto das gorgonas

## Montar lustre
 - adicionar 2 máquinas rocky8 na rede
 - testar lustre com 1 nó HEAD (manager + MSS) e 1 nó OSS
 - testar acesso ao DFS do nó login
   - testar permissões de usuários do LDAP
   - testar cotas de uso por projeto
 - montar lustre HEAD em cerberus2
 - mover nó OSS para HEAD em cerberus2
 - iniciar descontinuação do nó tmp sshfs
   - iniciar periodo de 1 mês para remoção do nó
   - nesse periodo todos usuários deverão passar seus dados para o lustre
