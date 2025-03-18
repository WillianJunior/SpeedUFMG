# Recomendções de Etiqueta de Perguntas

Ao encontrar um problema aparentemente intransponível com o cluster existe um workflow de resolução que deve ser seguido. Primeiramente, busque informações no [FAQ](user/faq.md). Tem vários problemas já resolvidos descritos lá. Os problemas encontrados lá são atualizados com mudanças no cluster e novas informações. Segundo, tente buscar informações na documentação geral do cluster. Caso você saiba que esse problema seja recorrente com outros usuários, seria interessante submeter essa dúvida com a solução usada, no Telegram. Isso ajuda muito seus colegas pesquisadores.

Caso não tenha uma solução para esse problema disponível na documentação você deverá submeter a sua dúvida no grupo do Telegram. Porém, não tem como ajudar quando a dúvida é "meu programa não tá rodando", ou "parou de funcionar". Para facilitar o processo de resolver eventuais problemas algumas informações são importantes:
 - ID do job
 - Script usado para o batch job (idealmente), ou script usado para replicar o problema
 - Path de onde foi rodado o experimento
 - Exemplo de stdout mostrando o problema, inclusive a chamada do script com problemas

Um exemplo de como pedir ajuda com um [problema da FAQ](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/faq.md#2-o-module-python3121-n%C3%A3o-est%C3%A1-carregando-mostrando-apenas-o-python310):

## Ruim:

*Tá dando problema no meu python. Não tá rodando meu código no cluster, mas roda na minha maquina tranquilo. Parece que a versão tá errada.*

Com a descrição acima não tem como resolver sem ter que ficar trocando mensagem, brincando de [20 perguntas](https://en.wikipedia.org/wiki/Twenty_questions).

## Bom:

*Eu rodei o seguinte script: /home_cerberus/speed/username/run1.sh da seguinte forma:*
``` comand
username@phocus4:~$ pwd
/home_cerberus/speed/username
username@phocus4:~$ sbatch run1.sh
Submitted batch job 1709
```

``` bash
#!/bin/bash run1.sh
#SBATCH --time=00:05:00       	  # Time limit hrs:min:sec
#SBATCH -N 1            	        # Number of nodes

set -x # all comands are also outputted

cd /home_cerberus/speed/username

module load python3.12.1
python3 --version

source myenv1/bin/activate

python3 test.py
```

*Na saída do slurm (em /home_cerberus/speed/username/slurm-1709.out) a versão do python3 estava errada mesmo após o module load. O que eu devo fazer para carregar a versão 3.12.1?*

No caso acima foi mostrado claramente (i) o que foi executado e por qual usuário (username), (ii) como foi executado, facilitando a replicação do problema, (iii) o log de saída caso seja muito grande para colar no chat, e (iv) finaliza com uma pergunta direta que, respondida, levará quem perguntou a conseguir continuar os trabalhos. Não é necessário mandar os arquivos inteiros no chat, mas o path é importante. Você também pode enviar (Ctrl+Shift+c, Ctrl+Shift+v) a saída do terminal caso seja algo pequeno e bem descritivo.

Outro exemplo mais simples:

## Ruim:

*Não estou conseguindo entrar na phocus4.*

Não dá para saber qual é o seu usuário, como você fez para se conectar à phocus4 ou de onde.

## Bom:

*Não estou conseguindo entrar na phocus4. Eis o que aparece para mim:*

![image](https://github.com/user-attachments/assets/acea3f26-1dd3-4431-94e7-8e844b448aaa)

Já acima dá para saber que (i) é para o usuário willianjunior, (ii) que a conexão foi feita de um terminal linux, (iii) o problema está na conexão da cerberus para a phocus4 (não foi configurado o ~/.ssh/config), e (iv) que não foi usada chave ssh, apenas senha. Um Ctrl+c/Ctrl+v do texto do terminal sempre é melhor que um print, porém um print já serve.





