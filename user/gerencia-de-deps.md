# Dependências

Todos os nós, sejam eles de login ou de computação, possuem as mesmas versões de dependências basicas (e.g., vim, htop, git, ...). Para dependências mais complexas com dependência de drivers ou muito utilizadas, como uma versão específica de Python, CUDA ou MPI, o sistema environment modules (modules) do Linux é usado. Para dependências simples fora do ambiente Python, como uma versão específica do gcc, recomenda-se o uso da ferramenta Anaconda (disponível em modules). Para dependências mais simples no ambiente Python se recomenda o uso de venv.

## Environment modules

Por padrão, os nós do cluster são disponibilizados com o mínimo necessário de pacotes para seu uso. Ao usar uma ferramenta como CUDA ou Python é necessário baixar, compilar/instalar e configurar variáveis de ambiente para o seu uso. Por meio de modules podemos disponibilizar versões específicas dessas ferramentas que podem ser carregadas por qualquer usuário de maneira simples e rápida:

```comand
username@phocus4:~$ module list
No Modulefiles Currently Loaded.
username@phocus4:~$ module avail python
------------------------------------- /opt/Modules/modulefiles --------------------------------------
anaconda3.2023.09-0  modules      python3.10.12  
module-info          python3.7.6  python3.12.1  

Key:
modulepath  
username@phocus4:~$ python3 --version
Python 3.10.12
username@phocus4:~$ module load python3.12.1 
username@phocus4:~$ python3 --version
Python 3.12.1
```

Por meio dos comandos acima vemos que não existia nenhum modulo carregado, que existia um modulo Python disponível, e que conseguimos carrega-lo. É possível que mais de uma versão de um módulo exista, ficando à escolha do usuário qual versão é desejada. Ao carregar um módulo conflitante (e.g., carregar uma versão 3.12 do python tendo a versão 3.10 já carregada) os módulos conflitantes são descarregados antes de se realizar o carregamento do módulo pedido. Também é possível que um módulo tenha outros módulos como dependências. Nesse caso, esses módulos de dependências são carregados automaticamente.

Ao realizar o login em qualquer nó, este começara sem nenhum módulo carregado. Isso também vale para nós de computação assim como os nós de login. Ao acessar interativamente, será necessário carregar manualmente os módulos requeridos. Isso pode ser automatizado colocando os carregamentos de módulos em batch scripts a serem usados em batch jobs.

## Anaconda

A primeira etapa de usar o anaconda (conda) é o carregamento do mesmo:

```comand
username@phocus4:~$ module load anaconda3.2023.09-0 
username@phocus4:~$ conda --version
conda 23.7.4
```

Em seguida, podemos criar um conda env. Porém, existem algumas considerações:
 - O anaconda precisa de um path ~/ existente para manter dotfiles. Se não houver esse dir, **o conda env não será carregado**. Inicialmente esse path não existe nas gorgonas, porém pode ser criado facilmente indo para ele: 'cd ~'.
 - O local de geração do conda env importa, podendo ser gerado localmente (em uma gorgona específica) ou globalmente (na home_cerberus).
 - Globalmente é a melhor opção, já que somente será necessário fazer uma vez e acessado por todas as máquinas. Porém, dado que os dados globais estão montados na cerberus, podem ocorrer erros de input/output. Nestes casos crie ambientes locais para todas máquinas que desejar.
 - A criação do conda env global pode ser feita da phocus4 como de alguma gorgona. Tente primeiro fazer da phocus4. Caso não funcione, tente de uma gorgona. Caso não funcione, será necessário montar um env por máquina.

Abaixo temos um exemplo de como criar um conda env global a partir de uma gorgona. O processo é identico para a phocus4. Para cria localmente basta trocar o path do --prefix.

```comand
username@phocus4:~$ srun --time 10:00:00 --pty bash
username@gorgona5:~$ module load anaconda3.2023.09-0 
username@gorgona5:~$ conda --version
conda 23.7.4
username@gorgona5:~$ conda create --prefix /home_cerberus/disk3/username
[...]
username@gorgona5:~$ conda activate /home_cerberus/disk3/username
(/home_cerberus/disk3/username) username@gorgona5:~$
```

### OK, mas como isso me ajuda?
Tendo um ambiente conda você terá basicamente um 'apt install' de todo e qualquer pacote disponível no mundo conda (>25k no momento de escrita desse texto). Exemplo: preciso compilar meu código com o gcc-10.3, então preciso deste exato compilador. Basta ativar seu ambiente conda (ver acima) e instalar esses pacotes usando o comando 'conda install'. Quando em dúvida, buscar "conda install <nome_do_pacote>" no google normalmente resolve. Se buscar no conda-forge (maior repositório de pacotes conda) a página ainda mostra o comando que deve ser usado para instalar o pacote (exemplo: https://anaconda.org/conda-forge/gcc).

Para instalar um pacote (ainda usando o exemplo do gcc) basta carregar o seu ambiente conda e rodar o comando de instalação (note que existe uma forma de instalar versões específicas de pacotes):
```comand
username@gorgona5:~$ conda activate /home_cerberus/disk3/username
(/home_cerberus/disk3/username) username@gorgona5:~$ conda search gcc
Loading channels: done
# Name                       Version           Build  Channel             
[...]      
gcc                            9.5.0     h1fea6ba_13  conda-forge         
gcc                           10.3.0      he2824d0_1  conda-forge         
gcc                           10.3.0     he2824d0_10  conda-forge         
gcc                           10.3.0      he2824d0_2  conda-forge         
gcc                           10.3.0      he2824d0_3  conda-forge         
gcc                           10.3.0      he2824d0_4  conda-forge         
gcc                           10.3.0      he2824d0_5  conda-forge         
gcc                           10.3.0      he2824d0_6  conda-forge         
gcc                           10.3.0      he2824d0_7  conda-forge         
gcc                           10.3.0      he2824d0_8  conda-forge         
gcc                           10.3.0      he2824d0_9  conda-forge         
gcc                           10.4.0     hb92f740_10  conda-forge         
gcc                           10.4.0     hb92f740_11  conda-forge         
gcc                           10.4.0     hb92f740_12  conda-forge         
gcc                           10.4.0     hb92f740_13  conda-forge         
gcc                           11.1.0      hee54495_1  conda-forge
[...]   
gcc                           13.2.0      hd6cf55c_2  conda-forge         
gcc                           13.2.0      hd6cf55c_3  conda-forge         
gcc                           13.3.0      h9576a4e_0  conda-forge         
gcc                           14.1.0      h6f9ffa1_0  conda-forge 
(/home_cerberus/disk3/username) username@gorgona5:~$ conda install gcc=10.3
Channels:
 - conda-forge
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: done

## Package Plan ##

  environment location: /home_cerberus/disk3/willianjunior2

  added / updated specs:
    - gcc=10.3


The following packages will be downloaded:

    package                    |            build
    ---------------------------|-----------------
    binutils_impl_linux-64-2.36.1|       h193b22a_2        10.4 MB  conda-forge
[...]
(/home_cerberus/disk3/username) username@gorgona5:~$ gcc --version
gcc (conda-forge gcc 10.3.0-0) 10.3.0
Copyright (C) 2020 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```


## Python venv

Como os usuários não possuem acesso root, não é possível instalar pacotes Python diretamente via pip. Para isso, é necessária a criação de um venv:

```comand
username@phocus4:~$ python3 -m venv /home_cerberus/speed/username/my-venv
username@phocus4:~$ source /home_cerberus/speed/username/my-venv/bin/activate
(my-venv) username@phocus4:~$
```

Notem que ao ativar o venv, o seu nome aparece no inicio das linhas de comando. Tendo ativado o venv, é possível usar o pip normalmente. O venv deve ser ativado ao inicio de toda sessão, mesmo acessando nós de computação (algo também interessante de fazer em um batch script). Pacotes Python instalados em um venv são persistentes, e pode ser acessados após carregamento do venv. É possível criar vários venvs.

Um detalhe importante para se atentar é que a versão do Python usada para gerar o venv e usá-lo  devem ser as mesmas. Caso não seja, é possível que hajam problemas de compatibilidade. Uma forma de se certificar que a versão está correta é por meio do carregamento de modules correto.

## TLDR
 - Primeiro, busque a dependencia no modules.
 - Se não houver, e for uma dependência Python, use venv.
 - Se for algo mais complexo, use Anaconda
