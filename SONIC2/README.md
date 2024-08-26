# Planejamento da segunda iteração do cluster SONIC

# Iteração Anterior
 - Sistema slurm de fila
 - Storage: sshfs
 - Gestão de dependencias:
   - Linux modules
   - Anadonda
   - Ansible para aplicar alterações em todos nós
  
## Demandas
 - Configuração PAM para execução mpi multi-nós
 - DFS lustre

# Objetivos da Nova Iteração
 - Formalizar configuração de novas máquinas do zero
 - Mudar SO padrão para rocky linux
 - Montar rede NAT privada para facilitar controle do cluster
 - Implementar DFS lustre
 - Implementar nó login separado do nó HEAD
 - Bloquear acesso de usuários em cerberus2, exceto para ssh para nó de login
 - Migrar máquinas para nova subrede

## Progresso
 - [ ] Montagem da subrede NAT privada
   - [x] Formatar cerberus2 com rocky8
   - [x] Adicionar cerberus2 ao DNS da rede do DCC (fora da NAT privada)
   - [x] Montar DHCP em cerberus2
   - [ ] Formatar gibraltar1 (nó de login) com rocky8
   - [x] Formatar alexandria1 (nó de armazenamento lustre) com rocky8
   - [ ] Adicionar acesso à internet de alexandria1 via cerberus2->mica->internet
   - [ ] Bloquear acesso à cerberus2, exceto root, permitindo apenas tunelamento ssh
 - [ ] Implementar lustre DFS
   - [ ] Instalar lustre head server em cerberus2
   - [ ] Instalar lustre data server em alexandria1
   - [ ] Instalar lustre client em gibraltar1
 - [ ] Configurar LDAP
   - [x] Pingar LDAP do DCC
   - [x] Configurar LDAP na cerberus2
   - [ ] Configurar LDAP na gibraltar1
   - [ ] **Necessário configurar LDAP na alexandria1? Lustre precisa disso?**


