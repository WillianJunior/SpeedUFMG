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
 - DFS/NFS

# Objetivos da Nova Iteração
 - Formalizar configuração de novas máquinas do zero
 - Mudar SO padrão para rocky linux
 - Implementar NFS
 - Implementar nó login separado do nó HEAD
 - Arrumar avisos slurm por email
 - Arrumar slurm PAM para nós compute corretamente (solução com script de kill está dando problemas as vezes...)
 - Montar NFS com config files globais
 - Criar script de reboot para nós compute (RebootProgram em slurm.conf)

## Wishlist para próxima iteração
 - Montar sistema de quotas por projeto
 - Montar monitoramento de uso do lustre (latencia, throughput, storage, ...)

## Lições até agora...
 - Todos nós precisam do ldap para genrenciar usuários, até mesmo NFS
 - Remover acesso ssh de usuários para nós que não sejam login ou compute
 - vg+lv e zfs são dificeis....
 - caso não seja possível matar um lv (Logical volume in use), pode ser que o "in use" seja do zfs, então basta um 'zpool destroy' antes...
 - mdadm para raid no lustre não deu bom
 - ao criar um fs (com os ost's no zpool) com o mesmo nome de um fs que foi apagado antes, pode rolar um "The target service's index is already in use.", neste caso será necessário trocar o nome do fs...
 - resumindo, zfs não é tão difícil, eu q não sabia...


## Progresso NFS (tails1)
 - [ ] format rocky9.5
 - [ ] block ssh from non root, only allow public-key access
 - [ ] install nfs server
 - [ ] /setc (shared_etc) (nfs mount) (32GB)
   - no quotas, other-r-w-x
   - user access controled by service
   - [ ] slurm configs
     - slurm.conf
   - [ ] network configs
     - hosts
   - [ ] ldap configs
     - sssd.conf
   - [ ] fs configs
   - [ ] munge key
 - [ ] /smodules (shared_modules) (nfs mount) (512GB)
   - [ ] modules install
   - [ ] modules definitions
 - [ ] /scratch1 (storage nfs 1) (3TB)
   - [ ] /scratch1/speed (speed project)
 - [ ] ldap

## Progresso nó Head (sonic1)
 - [ ] format rocky9.5
 - [ ] block ssh from non root, only allow public-key access
 - [ ] install nfs client and fscache
 - [ ] mount /setc (with fscache)
 - [ ] slurm
   - [ ] slurm head
   - [ ] slurmdb
   - [ ] mail notification (s-nail + smtp do crc)

## Progresso nós login (eggman1) / compute (gorgonas...) (knuckles1-8)
 - [ ] format rocky9.5
 - [ ] ldap
 - [ ] mount /setc (with fscache)
 - [ ] mount /smodules (with fscache)
 - [ ] mount /scratch1
 - [ ] slurm client
 - [ ] PAM (ver https://www.suse.com/c/deploying-slurm-pam-modules-on-sle-compute-nodes/)








