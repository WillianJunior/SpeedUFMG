# Planejamento da próxima iteração do cluster `tartarus`

> In Greek mythology, Tartarus is the deep abyss that is used as a dungeon of torment and suffering for the wicked and as the prison for the Titans.

 - rocky 9
 - inicialmente bash scripts para configuração
 - tentar migrar para ansible

## Management
 - `typhon`
 - nó único de gestão
 - mantêm o slurmctrl, slurmdb
 - mantêm um nfs com o shared /etc e o shared modulefiles
 - somente acesso admin
 - política de fila: apenas fairshare
 - projetos: 1 conta por professor, alunos entram na conta do professor. fairshare por professor, por aluno
   - possibilidade: podemos aumentar o número de cotas por professor, sendo inicialmente 1 cota por aluno para cada professor

## Login
 - `charon`
 - ldap do CRC
 - acesso apenas via login.dcc.ufmg.br
 - apenas usuários do grupo speed podem acessar
 - sem swap? (a depender da memória do nó)
 - limite de memória por user: 2G (a depender da memória do nó)
 - proibido o uso de agentes llm direto no nó de login (aloque um nó compute se precisar)
 - segundo nó de login (`pandora`) onde tudo é permitido? sem limite de processos, memória ou computação

## Storage
 - precisa de ldap
 - acesso direto apenas via admin
 - `ladon`
   - /home
   - nfs
   - deve ser otimizado para arquivos pequenos
   - quota por usuário
 - `atlas`
   - /prj
   - se precisar, distribuído com o storage das medusas
   - beegfs foi interessante, mas precisa do pago para permitir redundância (importante para manutenção de nós ou quando precisa de um reboot)
   - cephfs TODO: testar...
   - sem quotas
   - otimizado para arquivos grandes
   - 1x por ano, apagar todos arquivos com mais de 24 meses sem acesso (hecatombe)
 - storage local
   - /scratch
   - limpo quinzenalmente
     - criar um serviço systemd em `typhon` que submete um job como root que faz o `rm -rf /scratch/*` a cada 15 dias
     - 15 dias podem ser trocados por mais caso não haja tanta pressão no /scratch
  
## Dependências
 - modules environment:
   - poucas versões de cuda
   - anaconda
   - apptainer
   - mpi

## Compute
 - sem acesso ssh direto. usar ` srun --jobid=<JOB_ID> --overlap --pty bash`
 - 1 fila dev com 1 gorgona. uso exclusivo apenas
 - 1 fila gorgonas com tempo ilimitado. uso exclusivo apenas
 - 1 fila medusas com 48hrs máximo. uso shared por gpu.

## Governança
 - todos avisos via telegram (tópico avisos)
 - novos usuários via telegram (tópico novos usuários)
 - suporte via telegram (tópico dúvidas)
 - registro no git de eventos (quedas de energia, falhas de nós, problemas de uso de storage, ...)

## Sonhos 
 - comprar um nó de storage exclusivo (seja /home ou /prj)
 - melhorar a rede: medusas com ethernet 5Gbps e gorgonas e demais com ethernet 1Gbps. switch interno de 1Gbps
 - mover todas as máquinas para sala de máquinas: evitar acidentes com alunos esbarrando nos fios (relativamente comum)
 - mover máquinas para gabinetes de rack: melhor para acomodar em apenas 1 rack e atualizar a rede.
 - mudar para apenas hardware enterprise (com memória ecc, recursos mais lentos e com mais confiabilidade)
 - montar o nó `pandora`


