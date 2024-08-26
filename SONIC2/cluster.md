# Nós de Controle
Nós responsáveis por manter a rede e os serviços nela. Nós não acessíveis aos usuários

## cerberus2
 - ip externo: 150.164.203.178
 - ip: 169.254.231.10
 - Serviços:
   - [x] DHCP server
   - [ ] DNS server
   - [x] LDAP client
   - [ ] Slurm head
   - [ ] Luste head
   - [ ] Lustre MDS 
  
# Nós de Login
Nós onde usuários devem acessar e fazer o staging dos experimentos. Permite interface com slurm. Idealmente deve ter 1 nó com GPU para preparação de experimentos com GPU.

## gibraltar1
 - ip: 169.254.231.21
 - Serviços:
   - [ ] LDAP client
   - [ ] DHCP client
   - [ ] DNS client
   - [ ] Slurm client
   - [ ] Lustre client
  
# Nós DFS Lustre
Nós responsáveis pelo DFS. Existem 2 tipos diferentes para o sistema lustre: nós de metadados (MDS) e nós de dados (OSS). Serviço head reside em cerberus2. Nó inacessível a usuários.

## alexandria1
 - ip: 169.254.231.26
 - Serviços:
   - [ ] LDAP client (necessário para manter acesso de usuários? provavelmente não...)
   - [x] DHCP client
   - [ ] DNS client
   - [ ] Lustre OSS
  



