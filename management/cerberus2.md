# Cerberus2 intro
Cerberus2 é a máquina responsavel pela gestão de recursos no speed. Todos processos necessários para manter o lab (desde que não sejam jobs compute-heavy) são mantidos neste nó. Esses serviços são:
 - DHCP/DNS (ver [página de rede](management/rede.md))
 - Slurm HEAD (ver [gestão Slurm](management/slurm.md))
 - Lustre HEAD (ver [gestão Lustre](management/lustre.md))

# Gestão de Rede
No speed existem X subnets diferentes:
 - Nós de gestão: 104.201.56.1-10 (Nó cerberus2 está incluso)
 - Nós de login: 129.208.80.1-10 (ver [gestão de nós Login](management/login.md))
 - Nós de computação:
   - Gorgonas: 131.203.92.1-10
 - Nós Lustre (ver [gestão Lustre](management/lustre.md)):
   - Metadata Servers: 112.201.55.1-10
   - Object Servers: 112.201.55.11-50

As subnets acima são definidas autoritariamente pela cerberus2. Além disso, estão batizados os nós acima da seguinte forma: nodename[ID], sendo ID um número começando em 1. A numeração deve ser sem gaps. O binding dos nomes é gerido pelo DNS da cerberus2. Abaixo os hosts conhecidos:
 - cerberus2 (na rede existe apenas um nó cerberus ativo por vez)
 - gibraltar[1-] (nó de login)
 - wayfinder1 (Lustre Metadata Server)
 - alexandria1 (Lustre Object Server)
 - gorgona[1-10] (nós de computação)


