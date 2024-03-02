# Storage

O cluster possui dois tipos de espaço para armazenamento: local e distribuído. Armazenamento local é aquele presente fisicamente em cada nó usado, e é acessível apenas de seu nó. Armazenamento distribuído (DFS) é um espaço acessível globalmente por qualquer máquina no cluster. Pode-se imaginar dados nesse espaço como em um HD gigante conectado a todas as máquinas, ou em um serviço Google Drive ou Dropbox.

## Storage local

Para nós de login, não faz sentido acessar seu armazenamento local. Para nós de computação o storage local deve ser visto como um espaço temporário, limpo ao fim de cada job. Usar armazenamento local pode ser interessante para otimizar os tempos de acesso a dados, em casos específicos. Porém, vale lembrar que qualquer dado neste espaço de armazenamento é volátil, sendo necessário copiar explicitamente arquivos de interesse nele presentes para o DFS **antes do fim da alocação**. Para usar o storage local basta copiar seus arquivos para o diretório ‘/tmp’ do nó de computação sendo usado.

## Storage distribuído (DFS)

Dados globalmente acessíveis estão disponíveis no diretório ‘/home_cerberus/speed/username’. O diretório ‘/home_cerberus’ é montado em todas as máquinas (login e computação), e qualquer dado nele é visível em todo cluster. Neste ambiente é esperado que código, dados de entrada, resultados, scripts e logs sejam armazenados.

Atualmente o DFS não é distribuído, sendo um diretório da máquina cerberus montada em todos nós do cluster. Futuramente será usado o sistema Lustre para manter esses dados. Caso hajam problemas de acesso, sendo o mais recorrente '/home_cerberus' não estar montado, basta notificar no grupo do Telegram.

## Performance

Embora incomum, é possível que sua aplicação tenha perda de performance no acesso aos dados do DFS, principalmente se houverem várias operações pequenas de leitura. Para cada operação de leitura existe um overhead significativo pois os dados estão sendo acessados em um ambiente de rede. Uma forma de mitigar esse problema seria implementações que fazem carregamento de dados em bulk, assim amortizando o custo de leitura. Outra alternativa seria o uso do storage local. Porém, não é recomendado se preocupar com isso se não for identificado algum gargalo. Lembre-se, otimização prematura é a raiz de todo mal.

## TLDR
 - Usar principalmente DFS em  /home_cerberus/speed/username.
 - Dados no DFS são globalmente acessíveis por todos os nós do cluster.
 - Storage local pode ser usado, mas apenas quando for justificável (baixa performance de leitura do DFS).




