# Montando a home_cerberus
A home_cerberus é o dir /home no nó cerberus, e ela é montada em todas as máquinas no slurm. Ela pode ser unmonted/mounted com os seguintes comandos:

```command
sudo fusermount -u /home_cerberus
sudo sshfs -o allow_other -o follow_symlinks -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 cerberus:/home /home_cerberus/
```

A montagem deve ter alguns argumentos importantes:
 - allow_others: o mount é feito pelo root, mas deve ser acessível a todos os usuários.
 - follow_symlinks: todos os drives de storage da cerberus são montados em /home. Ao usar esse argumento todos os drives da cerberus são montados de tabela com apenas a montagem da sua /home.
 - reconnect,ServerAliveInterval=15,ServerAliveCountMax=3: Faz com que a home_cerberus possa ser remontada caso haja instabilidade na rede (ver https://serverfault.com/questions/6709/sshfs-mount-that-survives-disconnect). Porém, é possível que jobs em execução tenham seu progresso perdido por motivo de I/O.

É possível configurar as máquinas do cluster para montar automaticamente a home_cerberus. Basta adicionar a linha abaixo em /etc/fstab:
```command
cerberus:/home /home_cerberus fuse.sshfs x-systemd.automount,_netdev,users,exec,IdentityFile=/root/.ssh/id_rsa,allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,follow_symlinks 0 0
```
O método acima é de auto-mount on-demand, ou seja, a home_cerberus será montada assim que o primeiro acesso a ela for realizado. Isso permite que a cerberus realize seu boot antes de qualquer job entrar em execução, dado que para submeter um job é necessario passar pela cerberus/phocus4.
