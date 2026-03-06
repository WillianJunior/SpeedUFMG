# Rodando notebooks jupyter no slurm

Um notebook é apenas um código python que precisa rodar em algum servidor. No nosso caso, será usado um servidor jupyter.
Como clusters slurm não permiter a abertura de portas por usuários, será necessário realizar um roteamento da sua máquina para o servidor jupyter, a fim de ser possível acessá-lo de seu browser local. Esse processo de roteamento será feito via ssh, a única forma aceita de interação com o cluster.

## Passos para rodar seu notebook:

1. Preparar seu ambiente e instalando o jupyter
2. Submeter job que suba o servidor jupyter
3. Realizar tunelamento ssh com a sua máquina
4. Abrir notebook no browser.

## 1. Preparando seu ambiente e instalando o jupyter

A primeira tarefa será ter o jupyter instalado. Isso pode ser feito com uma simples venv. Abaixo os comandos para montar sua env:

```command
username@phocus4:/snfs2/username$ module load uv python/3.12.1
username@phocus4:/snfs2/username$ uv venv ./nb-env
Using Python 3.12.1 interpreter at: /opt/python/3-12-1/bin/python3
Creating virtualenv at: ./nb-env
Activate with: source nb-env/bin/activate
username@phocus4:/snfs2/username$ source nb-env/bin/activate
(nb-env) username@phocus4:/snfs2/username$ uv pip install jupyter
⠹ jupyter==1.1.1                                                                           
Resolved 97 packages in 2.86s
Downloaded 88 packages in 1.97s
Installed 97 packages in 9.76s
 + anyio==4.12.1
 + argon2-cffi==25.1.0
 + argon2-cffi-bindings==25.1.0
[...]
 + websocket-client==1.9.0
 + widgetsnbextension==4.0.15
(nb-env) username@phocus4:/snfs2/username$
```

Note que acima é usado o uv para montar o venv e instalar as depenências pip. Isso não é necessário. O venv/pip funciona normalmente, porém o uv costuma criar/instalar pacotes mais rapidamente.

## 2. Submetendo job que suba o servidor jupyter

Será usado o seguinte script de exemplo para submeter um job que suba o servidor jupyter.
 
Uma consideração muito importante: **ATENÇÃO COM O TEMPO!!!** Fechar o notebook no browser da sua máquina não termina o servidor jupyter. **VOCÊ AINDA ESTÁ RODANDO UM JOB!!!** Para reduzir o tempo de espera dos seus colegas de laboratório encerre o seu job quando terminar seus trabalhos. Para mitigar o problema de esquecer de encerrar o job, coloque um timeout razoável (e.g., 4hrs). Outra consideração: evitem usar máquinas muito grandes para esses jobs interativos (e.g., medusas).

Abaixo um script exemplo `notebook-example.sh`:

```bash
#!/bin/bash
#SBATCH --partition=gorgonas
#SBATCH --time=02:00:00
#SBATCH --mail-user=usernam@mail.com
#SBATCH --mail-type=ALL

module load uv python/3.12.1

cd /snfs2/username

# Estamos assumindo que o seu venv já foi criado
source nb-env/bin/activate

# Coloque seu exemplo de notebook aqui...
jupyter notebook example.ipynb --no-browser --port=8888 --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password=''
```

O job pode ser submetido via `sbatch notebook-example.sh`, que irá te enviar um email assim que o job entrar em execução. Também é possível usar o `srun notebook-example.sh`, mas antes é preciso permitir a sua execução com `chmod +x notebook-example.sh`.

## 3. Realizar tunelamento ssh com a sua máquina

Para que seu browser consiga acessar o nó alocado com o servidor jupyter é necessaŕio criar um tunel de comunicação entre o servidor e a sua máquina local. Esse tunel utiliza o protocolo ssh, que é a única forma de acesso permitida ao cluster. Esse tunelamento é feito via terminal, sendo necessário manter a conexão aberta. Enquanto a conexão estiver aberta, será possível acessar o seu notebook. Se a conexão cair, basta subir ela novamente para retomar acesso. Seu servidor jupyter ficará rodando até o job ser encerrado. Basta executar o comando a seguir para criar o tunelamento:

```command
username@my-machine:~$ ssh -N -L 8888:localhost:8888 -J phocus4 username@gorgona10
################################################  
#                    ATENCAO                   #
# Antes de efetuar o login, certifique-se que  #
# voce realmente tem autorizacao.              #
# Acessos nao autorizados e/ou tentativas de   #
# login serao monitoradas, armazenadas em log  #
# e serao devidamente reportadas ao CRC!       #
################################################

```

O comando acima irá ficar travado, sem aparecer nada. Isso é o comportamento correto. Se você tentar acessar um nó que não tem alocação, o seguinte irá acontecer:

```command
username@my-machine:~$ ssh -N -L 8888:localhost:8888 -J phocus4 username@gorgona10
################################################  
#                    ATENCAO                   #
# Antes de efetuar o login, certifique-se que  #
# voce realmente tem autorizacao.              #
# Acessos nao autorizados e/ou tentativas de   #
# login serao monitoradas, armazenadas em log  #
# e serao devidamente reportadas ao CRC!       #
################################################


Access denied by pam_slurm_adopt: you have no active jobs on this node

Connection closed by UNKNOWN port 65535
```

O acima não tem problema. Errar o nome do seu nó alocado não atrapalha ninguém.


## 4. Abrir notebook no browser.

Abra o seguinte link no seu browser: [http://localhost:8888](http://localhost:8888). Pronto! Você deve ter conseguido acesso ao notebook. Note que a porta 8888 é a mesma configurada no inicio do servidor jupyter e no tunelamento.

A fim de exemplo, um notebook simples que pode ser rodado.

```python
# example.ipynb
{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "intro",
   "metadata": {},
   "source": [
    "# SLURM Cluster Notebook Example\n",
    "\n",
    "This notebook runs on a compute node and demonstrates:\n",
    "\n",
    "- Checking the hostname\n",
    "- Inspecting CPU resources\n",
    "- Running a simple Python computation\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "hostname",
   "metadata": {},
   "outputs": [],
   "source": [
    "import socket\n",
    "hostname = socket.gethostname()\n",
    "print('Running on node:', hostname)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "resources",
   "metadata": {},
   "outputs": [],
   "source": [
    "import os\n",
    "\n",
    "print('SLURM job id:', os.environ.get('SLURM_JOB_ID'))\n",
    "print('SLURM cpus:', os.environ.get('SLURM_CPUS_PER_TASK'))\n",
    "print('Working directory:', os.getcwd())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "compute",
   "metadata": {},
   "outputs": [],
   "source": [
    "import numpy as np\n",
    "\n",
    "size = 2000\n",
    "A = np.random.rand(size, size)\n",
    "B = np.random.rand(size, size)\n",
    "\n",
    "C = A @ B\n",
    "\n",
    "print('Matrix multiply done, shape:', C.shape)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "plot",
   "metadata": {},
   "outputs": [],
   "source": [
    "import matplotlib.pyplot as plt\n",
    "import numpy as np\n",
    "\n",
    "x = np.linspace(0, 10, 200)\n",
    "y = np.sin(x)\n",
    "\n",
    "plt.plot(x, y)\n",
    "plt.title('Example Plot')\n",
    "plt.show()"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.x"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
```







