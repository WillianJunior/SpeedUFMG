# Nós de Controle
Nós responsáveis por manter a rede e os serviços nela. Nós não acessíveis aos usuários.
Para o caso da cerberus2, barreira de entrada para a rede, é possível tunelar ssh por ela. Ao acessá-la diretamente é disponibilizada uma interface para gerir chaves públicas dentro da cerberus2.

## cerberus2
 - ip externo: 150.164.203.178
 - ip: 169.254.231.10
 - Serviços:
   - [x] DHCP server
   - [ ] DNS server
   - [x] LDAP client
   - [ ] Slurm head
   - [x] Luste head
  
# Nós de Login
Nós onde usuários devem acessar e fazer o staging dos experimentos. Permite interface com slurm. Idealmente deve ter 1 nó com GPU para preparação de experimentos com GPU.

## ostia1
 - ip: 169.254.231.21
 - Serviços:
   - [x] LDAP client
   - [x] DHCP client
   - [ ] DNS client
   - [ ] Slurm client
   - [x] Lustre client
  
# Nós DFS Lustre
Nós responsáveis pelo DFS. Existem 2 tipos diferentes para o sistema lustre: nós de metadados (MDS) e nós de dados (OSS). Serviço head reside em cerberus2. Nó inacessível a usuários.

## alexandria1
 - ip: 169.254.231.26
 - Serviços:
   - [x] LDAP client (necessário para manter acesso de usuários? **SIM**)
   - [x] DHCP client
   - [ ] DNS client
   - [x] Lustre MGS 
   - [x] Lustre MDS 
   - [x] Lustre OSS
  



