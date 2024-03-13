# Soluções Paleativas

Roma não foi construída em um dia, e nem o nosso cluster. Ele é o resultado de melhorias incrementais, o que significa que existem vários problemas ou chatices para lidarmos. Neste texto são levantados alguns problemas recorrentes pelo sistema estar em montagem. Problemas esses onde podemos usar de soluções paleativas para conseguir usar o cluster do jeito que está enquanto uma solução permanente está em implementação.

## Storage
Atualmente não existe uma solução de DFS disponível no cluster. Ela será o lustre (já em estado de implementação). Porém é necessário haver um ambiente de acesso a arquivos consistênte entre todas as máquinas. No momento isso é implementado via o 'sshfs' do drive home_cerberus em todas as máquinas, o que embora seja uma solução inicial eficaz, não é muito eficiente.

### Problema 1. Espaço
A home_cerberus está em um drive de 1TB, o que não é muita coisa para vários usuários com dados grandes e 8 máquinas disponíveis para execução. Para mitigar problemas de espaço (já tivemos 100% da home_cerberus ocupada, atualmente nunca caindo de 70%) é possível manter seus dados maiores em um outro drive no nó cerberus. Ele conta com mais dois drives de 4TB cada: /dev/sdb1 montado em  /home/disk2 e /dev/sdc1 montado em /home/disk3 na cerberus. Pede-se então que usem os drives de 4TB para armazenamento de dados maiores, já que eles também são acessiveis via /home_cerberus/disk2 e /home_cerberus/disk3. Isso foi feito permitindo symlinks serem seguidos via 'sshfs'. Também é pedido que a quantidade de dados em /home_cerberus/speed/username seja mínima (tentem não exceder 10GB). Para padronizar a localização dos arquivos, é possível gerar um symlink de um disco de 4TB para home_cerberus/speed:

```bash

```

### Problema 2. Ownership
