# Storage

**DEPRECATION NOTE: a home_cerberus apresenta problemas diversos, principalmente de permissão de arquivos. EVITEM usar a `home_cerberus`. Usem outro storage global.**

O cluster possui três tipos de partição para armazenamento: `/scratch`, `/sonic_home`, e `/snfs1`. Cada uma delas é otimizada para um caso de uso específico. Essas partições tem as seguintes caracteristicas:

| | `/scratch` | `/sonic_home` | `/snfs1` |
|:---:|:---:|:---:|:---:|
| Visibilidade | Local | Global | Global |
| Volatilidade | Tempo da alocação | Persistente | Persistente |
| Quotas | Não | Por user | Por projeto |
| Desempenho<br>Arquivos<br>Pequenos | +++ | ++ | + |
| Desempenho<br>Arquivos<br>Grandes | +++ | ++ | ++ |
| Recomendaçao<br>de Uso | Copie seus arquivos que tem muito acesso aqui.<br>Zipar diretorios grandes com varios arquivos pequenos e descomprimir aqui. | Monte seus envs no `/scratch` e copie para `/sonic_home` ao fim, ou faça direto em `/sonic_home` (um pouco mais devagar) | Fique atento às permissoes de usuários. |
| Quando Usar | Aplicações I/O heavy em arquivos | Codigo, envs, dotfiles | Arquivos grandes ou compartilhados pelo grupo de projeto |

### Visibilidade
Global significa que todos os nós do cluster acessam o mesmo arquivo. Ou seja, ao alterar um arquivo em `gorgona4:/sonic_home/username/f.txt`, essa alteração será visível em `phocus4:/sonic_home/username/f.txt`. Isso acontece pois você estará acessando **o mesmo arquivo**.
Local significa que arquivos nessa partição são visíveis apenas no nó que mantém esse arquivo. Ou seja, um arquivo em `gorgona4:/scratch/username/f.txt` não é acessível fora da `gorgona4`.

### Volatilidade
Arquivos em partições volateis são apagados ao fim de um job. 
Arquivos em partições não-volateis persistem entre jobs e sessões de usuário. Ou seja, somente serão apagados diretamente pelo usuário.

### Quotas
Para evitar que poucos usuários monopilizem o espaço de armazenamento para seus arquivos, bloqueando o uso de outros usuários, o cluster conta com 2 sistemas de cotas de armazenamento. A partição `/scratch` não possui limite de uso, tendo em vista que é armazenamento local volátil.

Em `/sonic_home` cada usuário tem **160GB** de soft-limit e **200GB** de hard-limit. Caso o usuário tente exceder os 200GB, o SO retrnará um erro de falta de espaço. O limite de 160GB pode ser excedido por até 1 semana (até no máximo 200GB). Caso o limite de 160GB permaneça excedido por 1 semana ou mais, o SO retornará erro de falta de espaço para qualquer tentativa de alocação até que o usuário reduza seu uso para menos que 160GB.

Exemplo: digamos que você tenha usado 159GB em `/sonic_home`. No decorrer da execução de um job, é escrito 3GB de dados de saída em `/sonic_home`. A sua saída **não será perdida**. No decorrer de 1 semana, você conseguirá usar até 200GB. Digamos que após essa semana não houveram mais escritas, resultando em um uso de 162GB na `/sonic_home` por você. Qualquer operação de escrita que precise alocar mais storage será **bloqueada** pelo SO. Caso um job esteja rodando e tentando escrever neste momento **haverá perda das novas escritas**.

Atualmente a `/snfs1` não tem limite de quotas. Vamos tentar usar de forma razoável para não precisar implementar limites.

Como saber quanto espaço tenho? O comando `quota -s` mostra seu consumo e `du -sh` te ajuda a descobrir onde está sendo gasto o storage:

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

Como saber quanto espaço tem disponível no cluster? O comando `df -h -x tmpfs -x efivarfs` o uso de todas as partições:

```console
username@phocus4:~# df -h -x tmpfs -x efivarfs
Filesystem                          Size  Used Avail Use% Mounted on
/dev/sda2                            94G   60G   29G  68% /
/dev/sda4                           1.7T  609G  1.1T  38% /home
/dev/sda1                           476M  6.1M  469M   2% /boot/efi
cerberus:/home                      826G  752G   32G  96% /home_cerberus
150.164.203.121:/nfs/exports/snfs1  2.0T  1.5T  597G  71% /snfs1
tails1:/nfs/exports/sonic_etc        30G  258M   30G   1% /sonic_etc
tails1:/nfs/exports/sonic_home      3.3T  403G  2.9T  13% /sonic_home
tails1:/nfs/exports/sonic_modules   330G  2.4G  328G   1% /sonic_modules
```


# Considerações de Desempenho e Recomendações

Operações de I/O podem degradar severamente o desempenho de suas aplicações. Isso pode ser visto pelo comando `htop` mostrando o PSI:

## Execuções topadas. Uso máximo de CPU e GPU (`nvtop`):

<img width="741" height="221" alt="image" src="https://github.com/user-attachments/assets/defc3386-6012-4849-8123-4b41d74c2e1b" />
<img width="740" height="336" alt="image" src="https://github.com/user-attachments/assets/025f3db3-2042-4f2e-9158-309082b3893d" />


## Execução com gargalo de I/O. Provavelmente está tendo muita escrita. Vai demorar para sair os resultados:

<img width="740" height="222" alt="image" src="https://github.com/user-attachments/assets/02b6bbf8-7aa3-4089-9c87-bed7ed70b525" />

## Não necessariamente gargalando, mas muitos dados são guardados na file cache, provavelmente trabalhando com mais de 60 GB de dados:
<img width="684" height="222" alt="image" src="https://github.com/user-attachments/assets/6f9c10f1-3b8e-4df4-9262-e0cbef4ba00a" />


## Algumas recomendações:
 1. Se não tem problema, não precisa de solução. Comecem usando o `/sonic_home` e o `/snfs1`, e só busquem soluções quando problemas aparecerem.
 2. Tenho arquivos muito grandes (<60 GB) que são lidos apenas uma vez, o que faço? **Nada**. O sistema de file cache do linux vai carregar os seus dados apenas uma vez em memória. Próximos acessos serão feitos em memória.
 3. Tenho arquivos MUITO grandes (>60 GB) que são lidos com frequência pela minha execução, o que faço? **Copie os arquivos para o `/scratch` local**. Assim você copia uma vez e consegue acessar várias vezes.
 4. Meus arquivos não são tão grandes, mas fica aparecendo PSI de I/O. O que está acontecendo? Provavelmente você está escrevendo muito. Se houver muitas escritas, escreva em `/scratch`, e ao fim da execução copie para `/sonic_home` ou `/snfs1`. Lembre-se, se o job morrer antes **seus dados serão perdidos!!!**. Então cuidado.
 5. E as minhas dependências (venvs e conda envs), onde deixo elas? Deixe em `/sonic_home`. Ele foi otimizado para acesso de arquivos pequenos.

# Sobre a `/home_cerberus`

Historicamente ela deu muito trabalho. Como está em uma máquina legada, está sendo deixada para trás. Além disso, ela tem muitos problemas com permissões de usuários. 

TLDR: não começem a usá-la. Quem já usa, pode continuar usando ela como storage frio, mas escreva seus arquivos novos em outro storage global.
