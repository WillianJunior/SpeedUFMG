# Execução de Modelos LLM via SLURM (`sbatch`)
Este guia explica como configurar e rodar jobs de modelos Llama nas gorgonas utilizando o SLURM (`sbatch`).<br>
Todos os arquivos necessários para executar os modelos estão localizados dentro do diretório [Exemplo](./Exemplo).

## **Aviso:** 
Se já existir um ambiente virtual (`venv`) configurado e modelos Llama que pretenda utilizar baixados em `/snfs1/llm-models` ou em outro diretório acessível, **reutilize-os** em vez de criar novos venvs ou baixar modelos repetidos.
> OS recursos do laboratório são limitados, evite criar cópias desnecessárias.

## 1. Preparar o ambiente virtual (venv)
Primeiro, crie um ambiente virtual Python em um diretório compartilhado acessível por todas as gorgonas.<br>
Dentro dele, instale a biblioteca OpenAI, que será usada para fazer as requisições ao servidor do modelo.
```bash
# Cria o venv
python3 -m venv /snfs1/speed/user/venv

# Ativa o venv
source /snfs1/speed/user/venv/bin/activate

# Instala dependência
pip install openai
```
Esse caminho (`venv_dir`) será usado no arquivo de configuração.

## 2. Configurar o `config.json`
O arquivo `config.json` centraliza os parâmetros usados pelo `sbatch`. Variáveis:
- **job_name** → Nome do job no SLURM.
- **output_log** → Arquivo de log do SLURM com toda a execução.
- **result_dir** → Onde será salvo o resultado da inferência do modelo baseado na data e hora.
- **dir_llama_script** → Caminho do binário `llama-server` (compilado previamente).
- **model** → Caminho do modelo `.gguf` que será carregado.
- **port_rpc / port_server** → Portas para comunicação entre cliente e servidor.
- **venv_dir** → Caminho do ambiente virtual Python com a biblioteca `openai`.
- **prompt_server** → Arquivo com prompt de configuração do modelo
- **prompts_user_dir** → Diretório contendo arquivos de prompt `.txt` que serão analisados separadamente e incluídos no diretório de resultados
- **nodes** → Quantidade de nós (máquinas) que serão alocados.
    * Cada gorgona possui 20GB de VRAM, logo se um modelo tem tamanho 50GB, utilize 3 `nodes`
- **ntasks** → Quantidade de tarefas paralelas por job.
    * O mesmo vale para o item anterior: serão necessárias 3 tasks que acessam os 3 nós `nodes`
- **time** → Tempo máximo estimado de execução.
  - Deve cobrir o tempo de carregar o modelo + tempo da inferência.
  - Sempre coloque uma margem de segurança, pois o job encerra automaticamente ao concluir.
- **sbatch_script** → Script que será executado dentro do SLURM (ex.: `1-node_sbatch.sh`).

## 3. Executar o job
Para rodar, basta executar:
```bash
./run_sbatch.sh
```
Este script irá:
- Ler as variáveis do config.json.
- Limpar logs e criar diretorio de resultados baseado em data e hora.
- Submeter o job ao SLURM via sbatch.

Durante o processo, se o modelo não estiver já pré-carregado nas Gorgonas selecionadas pelo SBATCH, e se houver RPCs envolvidos, ocorrerão desconexões devido a testes iniciais entre o servidor e o RPC. Porém, em certo momento, ocorrerá uma conexão contínua que fará o modelo ser carregado de forma distribuída entre todos os nós selecionados no SBATCH, que detectará quando tudo estiver configurado e o servidor disponível para requisições, iniciando o envio de prompts para a resposta do modelo.

## 4. Fluxo resumido da execução interna
Dentro do sbatch_script:
- Os RPCs (se houver) serão inicializados.
- Um servidor Llama é iniciado em um nó das gorgonas.
- O script aguarda o servidor ficar disponível.
- Um cliente Python roda usando o venv, envia `prompt_server` e cada arquivo separado de `prompts_user_dir`, e grava cada saída separada dentro de `result_dir`.
- O servidor é encerrado automaticamente após a conclusão.

Assim você consegue rodar modelos Llama distribuídos via SLURM nas gorgonas com controle de logs, prompts e resultados.