# Storage

O cluster possui três tipos de partição para armazenamento: /scratch, /home e /prj. Essas partições tem as seguintes caracteristicas:

| | /scratch | /home | /prj |
|:---:|:---:|:---:|:---:|
| Visibilidade | Local | Global | Global |
| Volatilidade | Tempo da alocação | Persistente | Persistente |
| Quotas | Não | Por user | Por projeto |
| Desempenho<br>Arquivos<br>Pequenos | +++ | ++ | + |
| Desempenho<br>Arquivos<br>Grandes | +++ | ++ | ++ |
| Recomendaçao<br>de Uso | Copie seus arquivos que tem muito acesso aqui.<br>Zipar diretorios grandes com varios arquivos pequenos e descomprimir aqui. | Monte seus envs no /scratch e copie para /home ao fim, ou faça direto em /home (um pouco mais devagar) | Fique atento às permissoes de usuários. |
| Quando Usar | Aplicações I/O heavy em arquivos | Codigo, envs, dotfiles | Arquivos grandes ou compartilhados pelo grupo de projeto |

### Visibilidade
Global significa que todos os nós do cluster acessam o mesmo arquivo. Ou seja, ao alterar um arquivo em node1:/home/username/f.txt, essa alteração será visível em node2:/home/username/f.txt.
Local significa que arquivos nessa partição são visíveis apenas no nó que mantém esse arquivo.

### Volatilidade
Arquivos em partições volateis são apagados ao fim de um job. 
Arquivos em partições não-volateis persistem entre jobs e sessões de usuário. Ou seja, somente serão apagados diretamente pelo usuário.

### Quotas
Para evitar que poucos usuários terminem acumulando todo o espaço de armazenamento para seus arquivos, o cluster conta com 2 sistemas de cotas de armazenamento. A partição **/scratch** não possui limite de uso, tendo em vista que é armazenamento local volátil.

Em **/home** cada usuário tem **160GB** de soft-limit e **200GB** de hard-limit. Caso o usuário tente exceder os 200GB, o SO retrnará um erro de falta de espaço. O limite de 160GB pode ser excedido por até 1 semana (até no máximo 200GB). Caso o limite de 160GB permaneça excedido por 1 semana ou mais, o SO retornará erro de falta de espaço para qualquer tentativa de alocação até que o usuário reduza seu uso para menos que 160GB.

Em **/prj** Não implementado, TODO....

Como saber quanto espaço tenho? 'quota' mostra seu consumo e 'df' te ajuda a descobrir onde está sendo gasto o tempo:

```console
username@phocus4:~$ quota -s
Disk quotas for user username (uid 9999): 
     Filesystem   space   quota   limit   grace   files   quota   limit   grace
tails1:/nfs/exports/sonic_home
                 89636K    160G    200G            2849       0       0   
username@phocus4:~$ du -sh /sonic_home/username/*
200K	./infer-dset.txt
2,7M	./llama
6,0G	./Llama3.2-3B
4,0K	./prep.sh
4,0K	./run-llm1.py
4,0K	./run-llm2.py
28G	./vllm
```

### Desempenho e recomendações
Operações de I/O pode degradar severamente o desempenho de suas aplicações (usem htop mostrando o PSI para ver o dano). Para que seus jobs rodem mais rápido tentem seguir as seguintes recomendações:
 1. Usem /scratch sempre que possível para arquivos muito usados. Baixem esses dados de /prj ou /home para /scratch ao início do job. Caso precisem dos resultados em /scratch, não esqueça de copiar os arquivos de volta para /prj.
 2. Usem /home para envs e código. O /home é otimizado para arquivos pequenos, sendo a melhor solução para criar venvs, compilar código e editar seus scripts.
 3. O que não fica em /home vai para /prj.
