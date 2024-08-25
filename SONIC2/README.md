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
 - Migrar máquinas para nova subrede

## Progresso
 - [ ] Montagem da subrede NAT privada
   - [x] Formatar cerberus2 com rocky8
   - [ ] Adicionar cerberus2 ao DNS da rede do DCC (fora da NAT privada)
   - [ ] Montar DHCP em cerberus2
   - [ ] Formatar gibraltar1 (nó de login) com rocky8
   - [ ] Formatar alexandria1 (nó de armazenamento lustre) com rocky8
 - [ ] Implementar lustre DFS
   - [ ] Instalar lustre head server em cerberus2
   - [ ] Instalar lustre data server em alexandria1
   - [ ] Instalar lustre client em gibraltar1
 - [ ] Configurar LDAP
   - [x] Pingar LDAP do DCC
   - [x] Configurar LDAP na cerberus2
   - [ ] Configurar LDAP na gibraltar1
   - [ ] **Necessário configurar LDAP na alexandria1? Lustre precisa disso?**


