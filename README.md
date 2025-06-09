# Bem vindo ao SONIC
Este é o cluster de alto desempenho do laboratório SPEED do DCC/UFMG. Nele temos máquinas com diversas configurações para uso coletivo por meio do sistema slurm. Nesta página temos explicações completas do que está disponível para uso, assim como uma seção too long, didn’t read (TLDR) com informações resumidas para uso imediato do cluster.

Também temos um FAQ com material recente. Favor ler as dúvidas existentes caso tenha problemas. Naturalmente, por mais que tentemos, haverão gaps de informações nesta documentação, assim como possíveis problemas não recorrentes. Neste caso, pode-se pedir ajuda no grupo do Telegram, tentando se atentar a algumas [recomendações de etiqueta de perguntas](user/perguntas.md)

Por fim, temos uma seção com soluções paliativas para auxiliar o uso imediato do cluster, mesmo ele ainda não estando em sua forma final.

Um último detalhe importante: **NÃO RODEM JOBS NA PHOCUS4.** A phocus4 serve apenas como ponto de acesso ao cluster, onde só deve ser baixado e compilado código (dado que a compilação não acabe com a memória do sistema ou use todos os cores), ou submetido jobs para as gorgonas (via srun/sbatch). Rodar experimentos nela (i) vai ser devagar, já que ela é uma máquina antiga, e (ii) pode prejudicar o trabalho dos colegas. Como saber se estou usando a phocus4 excessivamente? rode o comando 'htop' quando conectado à ela. O htop mostra o uso de recursos de todos usuários, sendo possível filtrar por nome de usuário, nome do processo, etc., e verificar o uso de memória e cpu total do sistema, assim como todos os processos. Também é possível matar seus processos, caso vc encontre um processo seu rodando algo que não devia ser rodado.

 - [Como funciona?](user/como-funciona.md)
 - [Acessando o cluster](user/acesso.md)
 - [Como submeter jobs](user/submissao-slurm.md)
 - [Storage](user/storage.md)
 - [Gerenciando dependências](user/gerencia-de-deps.md)
 - [Prioridade de fila](user/prioridade-de-fila.md)
 - [Referência de filas](user/filas-atual.md)
 - [Referência de máquinas](user/nodes.md)
 - [FAQ](user/faq.md)
 - [Fazendo perguntas](user/perguntas.md)
 - [Soluções paliativas](user/gamba.md)

# Tópicos Legais
 - [Como rodar LLMs com mais de 1 nó em paralelo](https://github.com/TopologyMapping/network-security/tree/main/info-llm-speed-lab)

# Management
Essa é a parte de gerenciamento do cluster. Nela estão as etapas necessárias para montar o cluster do zero, ou fazer manutneção no mesmo. Se você não está prestando manutenção no cluster, não precisa ler nada daqui para baixo.

 - [Arquitetura (que tipo de nós tem)](link)
 - [Adição de recursos (comandos para colocar uma máquina nova)](link)
 - [Estatísticas de uso](management/stats.md)

## Ferramentas
 - [Ansible (gerenciando deps)](link)
 - [Slurm ()](link)
 - [Linux Environment Modules](link)
 - [Lustre (storage distribuído)](link)
 - [Reporting (métricas de uso do cluster)](link)
 - [Politica de filas (Mudanças e explicações)](link)
 - [TODO](link)
