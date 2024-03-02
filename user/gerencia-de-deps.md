# Dependências

Todos os nós, sejam eles de login ou de computação possuem as mesmas versões de dependências basicas (e.g., vim, htop, git, ...). Para dependências mais complexas com dependência de drivers ou muito utilizadas, como uma versão específica de Python, CUDA ou MPI, o sistema environment modules (modules) do Linux é usado. Para dependências simples fora do ambiente Python, como uma versão específica do gcc, recomenda-se o uso da ferramenta Anaconda (disponível em modules). Para dependências mais simples no ambiente Python se recomenda o uso de venv.

## Environment modules

Por padrão, os nós do cluster são disponibilizados com o mínimo necessário de pacotes para seu uso. Ao usar uma ferramenta como CUDA ou Python é necessário baixar, compilar/instalar e configurar variáveis de ambiente para o seu uso. Por meio de modules isso pode ser feito de maneira simples e rápida:

```comand
username@phocus4:~$ module list
No Modulefiles Currently Loaded.
username@phocus4:~$ module avail python
------------------------------------- /opt/Modules/modulefiles --------------------------------------
python3.12.1  

Key:
modulepath  
username@phocus4:~$ python3 --version
Python 3.10.12
username@phocus4:~$ module load python3.12.1 
username@phocus4:~$ python3 --version
Python 3.12.1
```

Por meio dos comandos acima vemos que não existia nenhum modulo carregado, que existia um modulo Python disponível, e que conseguimos carrega-lo. É possível que mais de uma versão de um módulo exista. Nesse caso módulos conflitantes são descarregados antes de se realizar o carregamento do módulo pedido. Também é possível que um módulo tenha outros módulos como dependências. Nesse caso, esses módulos de dependências são carregados automaticamente.

Ao realizar o login em qualquer nó, este começara sem nenhum módulo carregado. Isso também vale para nós de computação assim como os nós de login. Ao acessar interativamente, será necessário carregar manualmente os módulos requeridos. Isso pode ser automatizado colocando os carregamentos de módulos em batch scripts a serem usados em batch jobs.

## Anaconda

Ainda indisponível...

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
