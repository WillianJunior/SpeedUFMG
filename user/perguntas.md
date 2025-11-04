# Me Ajudando a te Ajudar

Problemas vão ocorrer. Eles podem ser do cluster, ou você pode ainda estar procurando como fazer algo corretamente. Independentemente do caso, queremos chegar à resposta o mais rápido possível, o que é bom para todos. Para isso, você pode seguir esses passos para resolver o seu problema o mais rapidamente possível.

## 1. Veja no [FAQ](user/faq.md)

Talvez esse problema já tenha ocorrido com outro colega, e já tenha sido resolvido. O FAQ é um ótimo lugar para começar, pois é mais resumido. Quando temos problemas recorrentes, tentamos atualizar a sua descrição no FAQ. Como usar ele rapidamente:
 1. Abra o FAQ;
 2. Busque nos tópicos (não precisa ler todas as respostas);
 3. Se não tiver nada que lhe ajude, vamos para o próximo passo.

É possível que você passe no FAQ e não encontre o seu problema, mesmo estando lá. Se for o caso, podemos te guiar até esta solução.

## 2. Busque nesta wiki

<img width="357" height="54" alt="image" src="https://github.com/user-attachments/assets/d3fe16b9-a88c-4cd7-b01a-1911d891939e" />

Todas as páginas da wiki são arquivos .md, então são indexaveis. Ao usar a barra de busca acima, você poderá encontrar o que precisa. Um exemplo abaixo do que acontece se buscarmos sobre um problema com ssh:

<img width="1004" height="601" alt="image" src="https://github.com/user-attachments/assets/0b6f0fba-e84c-4233-b2d9-27fb2918825c" />

## 3. Pergunte no grupo do telegram

Mais especificamente, pergunte no tópico Slurm. Se você perguntar em outro tópico iremos responder, porém pode ficar meio chato para aqueles que usam aquele tópico para outros fins. O tópico slurm foi criado para esse fim: resolver qualquer dúvida relacionado ao uso deste nosso cluster.

Porém, tendo em vista que queremos resolver o seu problema o mais rápido possível, aqui vão algumas dicas de como pedir ajuda por lá:

1. Mande prints ou Ctrl+c/Ctrl+v do terminal. A forma primária de interação com o cluster é via terminal ssh. Normalmente problemas tem esse formato: _Quero realizar algo. Este algo é realizavel via um ou mais comandos no terminal. Executei os comandos. O que queria realizar não foi realizado_. Só de olhar o(s) comando(s) já dá para ter uma noção boa do problema.
2. Seja descritivo. Uma dúvida geral como _não estou conseguindo rodar o meu job_ pode ser várias coisas. Vide acima: mandar o output do terminal resolve quase tudo.
3. Tente mostrar um exemplo mínimo de erro. Ou seja, com quais comandos executados a partir do seu usuário seria possível reproduzir o seu erro? Se você mandar isso (i) estará mostrando o terminal e (ii) estará descrevendo o resultado esperado. Isso nos ajuda imensamente.
4. Caso seja algum problema com um Job, mande também:
    - O ID do job;
    - Script usado para o batch job (idealmente), ou script usado para replicar o problema;
    - Path de onde foi rodado o experimento;
    - Path do arquivo de saída do job (slurm-<JOB_ID>.out).

### Exemplo

Digamos que estamos com problemas na hora de montar um ambiente de dependências python. O seu código cuspiu problemas de versão do python. Para este exemplo, o problema seria resolvivel por [esta entrada na FAQ](https://github.com/WillianJunior/SpeedUFMG/blob/main/user/faq.md#2-o-module-python3121-n%C3%A3o-est%C3%A1-carregando-mostrando-apenas-o-python310):

Digamos que você inicialmente não conseguiu encontrar o problema na FAQ. Embora esse problema seja buscavel, você também não conseguiu entender o que saiu da busca abaixo:
<img width="1004" height="643" alt="image" src="https://github.com/user-attachments/assets/3b0881bf-82de-41f1-8a21-7da7424b50be" />

Agora, estamos na parte de pedir ajuda no grupo do telegram. Se você enviar uma dúvida assim:

*Meu código não está rodando. Não sei se o python está instalado corretamente.*

não temos como entender o problema sem uma brincadeira de [20 perguntas](https://en.wikipedia.org/wiki/Twenty_questions). Alternativamente, você faz uma pergunta mais completa:

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

*Na saída do slurm (em /home_cerberus/speed/username/slurm-1709.out) apareceu um erro de versão.*

Agora sim podemos descobrir o problema. Se você soubesse que o problema é de versão, naturalmente você conseguiria já tê-lo resolvido. Porem da forma acima podemos descobrir exatamente o problema, possívelmente te orientando à entrada correta na página do FAQ.


### Outro exemplo mais simples, só com a pergunta:

*Não estou conseguindo entrar na phocus4.*

Não dá para saber qual é o seu usuário, como você fez para se conectar à phocus4 ou de onde.

*Não estou conseguindo entrar na phocus4. O que aparece para mim:*

![image](https://github.com/user-attachments/assets/acea3f26-1dd3-4431-94e7-8e844b448aaa)

Já acima dá para saber que (i) é para o usuário willianjunior, (ii) que a conexão foi feita de um terminal linux, (iii) o problema está na conexão da cerberus para a phocus4, que não deveria mais estar sendo feita, e (iv) que não foi usada chave ssh, apenas senha (não foi configurado o ~/.ssh/config). Um Ctrl+c/Ctrl+v do texto do terminal sempre é melhor que um print, já que também quero poder usar o Ctrl+c/Ctrl+v no seu texto, porém um print também serve.





