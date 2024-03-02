# Prioridade de Fila

Como dito antes, não existe limite de uso por pessoa. Exemplo, se houver apenas uma pessoa usando o cluster de 100 usuários totais (99 inativos), essa pessoa consegue usar todos os nós do cluster sem nenhuma limitação. Porém, entrando outras pessoas para usar o cluster, essas terão mais prioridade na fila. É possível ter vários jobs na fila por usuário.

## Fairshare

O sistema Slurm tem o conceito de *fairshare usage*, onde ele vai tentar ao máximo dividir igualmente o tempo total de uso entre usuários. Isso é feito por meio de uma fila dinâmica. Todo job tem um valor de prioridade. Este valor é proporcional aos recursos pedidos (quantidade de nós e tempo) e a uma métrica fairshare individual do usuário. Ao se usar o cluster esse valor fairshare diminui, representando que um usuário que estava usando muito o cluster antes está dando prioridade a quem não estava usando. Esse valor tem uma meia vida de uma semana, i.e., após uma semana, metade de todo fairshare que foi perdido é retornado.

 - **O que acontece se eu perder/zerar todo o meu fairshare?** Nada... Seus jobs ficarão no fim da fila. Se existem recursos disponíveis, esses serão alocados ao primeiro job da fila. Se não tiver mais gente usando (fila vazia) você será o último, mas também o primeiro na fila. Além disso, seu fairshare aumenta com tempo e o fairshare dos outros usuários também é reduzido com uso do cluster.
 - **Como o Slurm prioriza jobs baseado nos recursos pedidos?** Mais nós, menor prioridade. Mais tempo, **maior** a prioridade até um certo ponto (bell curve). Mais tempo esperando na fila, maior a prioridade.

O valor de prioridade de um job é atualizado periodicamente, podendo ter sua prioridade aumentada pois está muito tempo na fila, ou reduzida caso o dono desse job esteja usando muito o cluster (fairshare de usuário reduzido). Por fim, o Slurm penaliza o fairshare quando há uma discrepância muito grande entre tempo pedido e tempo usado pelo job. Porém, o pior que pode ocorrer é ter um job é tê-lo cancelado por limite de tempo e ter que executar de novo. Assim, é melhor colocar mais tempo, ~1 ordem de grandeza a mais do tempo esperado. Exemplo, acho que minha aplicação vai demorar uns 20 min, então vou pedir 1 hora de tempo.

Um último detalhe é que todos os jobs não são preemptivos. Uma vez que um job começa sua execução ele só será encerrado caso termine, seja cancelado pelo usuário que o submeteu ou com timeout. Jobs também usam recursos de maneira exclusiva, ou seja, se você tiver recursos alocados, apenas você poderá acessá-los até o fim da alocação.

# TLDR
 - Não se preocupe muito com prioridade, todos jobs submetidos são eventualmente executados
 - Peça 1 ordem de grandeza mais tempo do que você estimou, e.g., 1 hora para uma aplicação que espero rodar em 20 min. É sempre melhor pedir um pouco de tempo a mais do que ter que re-executar o experimento.
 - Pode colocar um tempo absurdamente grande (e.g., 2000 Hrs), porém a sua prioridade vai ser baixa, então vai demorar mais para rodar.
 - Quanto mais você usar o cluster, menor vai se a prioridade dos seus próximos jobs.
 - Jobs são não-preemptivos: começou a rodar, vai terminar sem interrupções.
 - Se você tiver uma prioridade “zero”, mas não houver mais ninguém na fila, os seu jobs são executados mesmo assim.












