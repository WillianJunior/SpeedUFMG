# Sistema de arquivos NFS (TRIAL)

**NOTA: o sistema snfs1 está em fase de testes. Assumam que seus arquivos nele possam ser perdidos. Havendo problemas notifiquem no grupo do Telegram para melhorarmos o uso dele :)**

Foi implementado um sistema NFS para storage compartilhado entre as máquinas do Sonic. Ele foi montado em todas as máquinas no path /snfs1. Em /snfs1 existe o dir /snfs1/speed. Em /snfs1/speed não é possível criar arquivos comuns, porém pode-se criar um dir pessoal para você usar, e neste dir usar seus arquivos normalmente. O snfs1 é equivalente às outras soluções de storage do Sonic, exceto que **venvs funcionam nele**. É possível criar uma venv em snfs1 em uma máquina (gorgona3 por exemplo) e carregar o mesmo venv em outra (gorgona10 por exemplo).

Outra diferênça é o desempenho. Aṕos benchmarks preliminares vimos que ele tem desempenho fraco para carregamento de arquivos pequenos (NFS usa comunicação via RPC e é bem verboso). Isso pode ser uma questão (i) do HD usado no host servidor, (ii) do desempenho de I/O e CPU/Mem do servidor, (iii) uma questão de rede, ou (iv) uma questão de má configuração da nossa parte. Então, fiquem atentos ao desempenho de I/O e notifiquem no Telegram problemas ou insights.

## Quotas

O snfs1 foi montado com cotas em mente. Isso significa que será possível limitar o uso de storage de usuários a nível de projetos. Atualmente **não tem limite**, porém estamos no processo de teste de sistemas de cotas.

### Como funciona:
Cotas em sistemas Linux (quotas) podem limitar o número de arquivos (inodes) ou blocos (tamanho total de arquivos) a nível de usuário, grupos (e.g., speed) ou projetos. Esses limites possuem 2 thresholds: soft e hard limit. O hard limit não permite que um usuário passe dele de forma alguma. Já o soft, permite que ele seja passado por um periodo de tempo (grace time). Após o grace time, qualquer requisição de alocação de storage será barrada até que o uso de storage reduza para menos que o soft limit.

Exemplo: Temos um hard limit de 10G, um soft limit de 5G e um grace time de 1 semana. 
 - Começo a trabalhar usando 4G de storage. Resultado: nada acontece. Porém tenho um limite "teorico" de 10G de espaço para usar
 - Nos trabalhos chego a usar 7G. Resultado: consigo usar os 7G, porém meu grace time começa a contar
 - Grace time vence. Resultado: não consigo mais criar novos arquivos ou pedir mais espaço (Out of space error)
 - Apago 5G de dados, tendo agora só 2G de dados. Resultado: Assim que meu uso cair de 5G terei "em teoria" 10G de limite novamente.

### Sobre usuários, grupos e projetos:
Limites diferentes podem ser aplicados a usuários ou grupos de forma individual. Também é possível criar uma entidade de grão mais fino chamada projeto. Em snfs1 **apenas quotas de projeto serão usadas**. Atualmente existe apenas 1 projeto (speed) que todos podem usar. Para evitar que o storage fique cheio ao ponto de inviabilizar o seu uso por outros usuários, também será possível realizar alocações de projetos. Aqueles que começarem a usar o snfs1 e se sentirem confortaveis com ele poderão pedir a criação de um projeto no tópico "Novos Acessos" no Telegram. Será feita uma alocação exclusiva para o projeto, sendo possível criar um grupo unix a fim de permitir apenas que usuários deste grupo acessem esse projeto.

### Qual é o meu uso?
Existem ferramentas para verificação de quotas e quanto dela você está usando. Porém, para as tecnologias usadas para implementar o snfs1 (xfs por NFS) não é possível ainda verificar uso de quotas remotamente (como pela phocus4). Isso é algo que está em desenvolvimento e será implementado no futuro. Porém é possível verificar o uso global via df:

```command
username@phocus4:~$ df -h
Filesystem                          Size  Used Avail Use% Mounted on
tmpfs                               1.6G  2.3M  1.6G   1% /run
/dev/sda2                            94G   29G   61G  32% /
tmpfs                               7.9G     0  7.9G   0% /dev/shm
tmpfs                               5.0M     0  5.0M   0% /run/lock
efivarfs                             72K   39K   29K  58% /sys/firmware/efi/efivars
/dev/sda1                           476M  6.1M  469M   2% /boot/efi
/dev/sda4                           1.7T  557G  1.1T  35% /home
cerberus:/home                      826G  774G   11G  99% /home_cerberus
150.164.203.121:/nfs/exports/snfs1  2.0T   15G  2.0T   1% /snfs1
```

Como visto, são 2TB de storage inicial, com mais storage a ser adicionado no futuro.













