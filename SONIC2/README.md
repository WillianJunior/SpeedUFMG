# Planejamento da segunda iteração do cluster SONIC

# Iteração Anterior
 - Sistema slurm de fila
 - Storage: sshfs
 - Gestão de dependencias:
   - Linux modules
   - Anaconda
   - Ansible para aplicar alterações em todos nós
  
## Demandas
 - Configuração PAM para execução mpi multi-nós
 - DFS lustre

# Objetivos da Nova Iteração
 - Formalizar configuração de novas máquinas do zero
 - Mudar SO padrão para rocky linux
 - Montar rede NAT privada para facilitar controle do cluster
 - Implementar DFS lustre com suporte a high-availability (raid e demais...)
 - Implementar nó login separado do nó HEAD
 - Arrumar avisos slurm por email
 - Arrumar slurm PAM para nós compute
 - Bloquear acesso de usuários em cerberus2, exceto para ssh para nó de login
 - Migrar máquinas para nova subrede

## Wishlist para próxima iteração
 - Montar sistema de quotas no lustre
 - Montar monitoramento de uso do lustre (latencia, throughput, storage, ...)

## Lições até agora...
 - Todos nós precisam do ldap para genrenciar usuários, até mesmo alexandria
 - Remover acesso ssh de usuários para nós lustre
 - vg+lv e zfs são dificeis....
 - caso não seja possível matar um lv (Logical volume in use), pode ser que o "in use" seja do zfs, então basta um 'zpool destroy' antes...
 - mdadm para raid no lustre não deu bom
 - ao criar um fs (com os ost's no zpool) com o mesmo nome de um fs que foi apagado antes, pode rolar um "The target service's index is already in use.", neste caso será necessário trocar o nome do fs...
 - resumindo, zfs não é tão difícil, eu q não sabia...
 - caso hajam dados sensíveis, que devem ser compartilhados com outros usuários específicos de algum projeto, usem ACL (setfacl -m u:username:rw path/to/file)

## Progresso Sprint 1
 - [ ] Montagem da subrede NAT privada
   - [x] Formatar cerberus2 com rocky8
   - [x] Adicionar cerberus2 ao DNS da rede do DCC (fora da NAT privada)
   - [x] Montar DHCP em cerberus2
   - [x] Formatar ostia1 (nó de login) com rocky8
   - [x] Formatar alexandria1 (nó de armazenamento lustre) com rocky8
   - [ ] Adicionar acesso à internet de alexandria1 via cerberus2->mica->internet
   - [ ] Remover alexandria1 da rede dcc 
   - [x] Bloquear acesso à cerberus2, exceto root, permitindo apenas tunelamento ssh
 - [x] Implementar lustre DFS
   - [x] Instalar lustre em alexandria1
   - [x] Instalar lustre client em cerberus2
   - [x] Conseguir montar s2common de alexandria1 em cerberus2
   - [x] Instalar lustre client em ostia1
 - [x] Configuração de startup
   - [x] Configuração de ip estático da cerberus2
   - [x] Startup DHCP da cerberus2
   - [x] Configuração de ip de DHCP da alexandria1
   - [x] Startup lustre da alexandria1
   - [x] Startup LNet da alexandria1
   - [x] Startup LNet da cerberus2
   - [x] Montagem s2common em cerberus2
   - [x] Montagem s2common em ostia1
 - [x] Configurar LDAP
   - [x] Pingar LDAP do DCC
   - [x] Configurar LDAP na cerberus2
   - [x] Configurar LDAP na ostia1
   - [x] Configurar LDAP na alexandria1

## Progresso Sprint 2
 - [ ] Montagem slurm
   - [x] Instalar slurm server em cerberus2
   - [x] Montar login node em ostia1
   - [x] Configurar compute node em cerberus2 para testes
   - [ ] Descobrir como configurar PAM... (ver https://www.suse.com/c/deploying-slurm-pam-modules-on-sle-compute-nodes/)
   - [ ] Configurar notificação por email (ver com CRC? also: https://www.claudiokuenzler.com/blog/1360/where-is-mailx-command-rocky-linux-el-9-s-nail-package)
 - [ ] Configuração userspace lustre
   - [x] Montar estrutura de diretórios
     - Todos usuários tem um diretório pessoal em /s2_scr4/speed
     - Por padrão, todos arquivos/dirs são inicializados como o+rx
     - Para controle grão-fino, ou dar permissão de escrita/leitura para usuários de um mesmo projeto, basta o usuário usar ACL nos seus arquivos
   - [x] Descobrir como funciona raidz no lustre
 - [ ] Preparação para migração
   - [ ] Encontrar ponto de acesso da NAT privada para as gorgonas

## Progresso Sprint 3
 - [ ] Documentação
   - [ ] Preparar scripts ansible para preparação de todos os nós
   - [ ] Documentação de instalação dos nós
 - [ ] Testes
   - [ ] Validação do fs (acesso, permissões, disponibilidade, tolerancia a falhas...)
   - [ ] Validação execução slurm
   - [ ] Validação desempenho de I/O (execução de jobs baixando arquivos)
