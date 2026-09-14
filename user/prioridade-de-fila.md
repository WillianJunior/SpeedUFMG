# Prioridade de Fila

Não existe limite de tempo de uso do cluster, ou seja, havendo recursos livres você poderá usá-los. Porém, existem mais usuários do que máquinas no cluster. Dessa forma, o cluster precisa ordenar o uso das máquinas pelos usuários. Para isso, todo job possui uma prioridade, e a partir desse valor, seu job irá executar mais cedo ou mais tarde. A prioridade do job é influenciada majoritariamente por uma métrica de *fairshare*. Ou seja, quanto mais você usa tempo de alocação, menor é a sua prioridade. Notem que isso só importa quando há mais jobs na fila. Se apenas você está na fila, seu job irá executar. A prioridade perdida por tempo de uso é automaticamente recuperada com tempo passado. Dessa forma, fica mais difícil de termos apenas um usuário usando o cluster sozinho. Outro detalhe: as métricas de prioridade (fairshare incluso) são atualizadas a cada 5 min. Ou seja, um usuário com 100 jobs e 2 em execução não ficará no topo da fila indefinidamente. Seu job novo pode ser o próximo a ser executado, dado que você tenha uma prioridade mais alta.
alocados, apenas você poderá acessá-los até o fim da alocação.

# Como Descobrir Prioridades?

Prioridade para o meu job (pelo job ID):
```command
username@phocus4:~# sprio -j 41527
          JOBID PARTITION   PRIORITY       SITE        AGE  FAIRSHARE    JOBSIZE
          41527 gorgonas          86          0          2         85          0
```

Prioridade para o meu (ou outro) usuário. Quão maior o seu FairShare, maior a prioridade dos seus jobs:
```command
username@phocus4:~# sshare -U -u pedroroblesduten
Account               User  RawShares  NormShares    RawUsage  EffectvUsage  FairShare
--------------- ---------- ---------- ----------- ----------- ------------- ----------
username_acc    username+          1    1.000000    35615192      1.000000   0.003521
```

Como está o uso do cluster para todos os usuários em horas por job (note o parâmetro de start time)? 
```command
username@phocus4:~# sacct -a -X --starttime 2026-08-01   --format=User,ElapsedRaw -n -P | awk -F'|' '{t[$1]+=$2} END {for (u in t) print u, t[u]/3600}' | sort -k2,2nr
username 1325
username 1134.568
username 1001.123
username 995.236
```

Observações:
 - Jobs com dependências não podem ser escalonados, dessa forma não tem prioridade. Para todos os efeitos, jobs que não estejam com o reason (Priority) ou (Resources) **não estão na fila**.
 - Maior FairShare, maior a prioridade dos seus jobs.
 - Mais tempo de uso, menor o seu FairShare.
 - Evitem gastar tempo à toa. Tempo gasto hoje pode ser tempo que será priorizado para outro usuário amanhã.

# TLDR
 - Não se preocupe muito com prioridade, todos jobs submetidos são eventualmente executados
 - Peça 1 ordem de grandeza mais tempo do que você estimou, e.g., 1 hora para uma aplicação que espero rodar em 20 min. É sempre melhor pedir um pouco de tempo a mais do que ter que re-executar o experimento.
 - Quanto mais você usar o cluster, menor vai se a prioridade dos seus próximos jobs.
 - Jobs são não-preemptivos: começou a rodar, vai terminar sem interrupções.
 - Se você tiver uma prioridade “zero”, mas não houver mais ninguém na fila, os seu jobs são executados mesmo assim.












