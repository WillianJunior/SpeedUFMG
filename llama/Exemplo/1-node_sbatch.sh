#!/bin/bash

get_ip() {
    local node=$1
    srun --nodes=1 --nodelist=$node hostname -I | awk '{print $1}'
}

echo "Nós alocados pelo SLURM: $SLURM_NODELIST"
ALLOCATED_NODES=($(scontrol show hostnames $SLURM_NODELIST))

if [ ${#ALLOCATED_NODES[@]} -lt 1 ]; then
    echo "Erro: Nenhum nó foi alocado."
    exit 1
fi

SERVER_HOSTNAME=${ALLOCATED_NODES[0]}
echo "SERVER será executado em: $SERVER_HOSTNAME"

# Obtém o IP correspondente ao nó
IP_SERVER=$(get_ip "$SERVER_HOSTNAME")
if [[ -z "$IP_SERVER" ]]; then
    echo "Erro: IP não resolvido."
    exit 1
fi

echo "Iniciando servidor Llama em $SERVER_HOSTNAME ($IP_SERVER:$PORT_SERVER)..."
srun --nodes=1 --nodelist=$SERVER_HOSTNAME --partition=gorgonas bash -c "
cd $DIR_LLAMA_SCRIPT
./llama-server -m $MODEL -c 8192 -ngl 99 --host $IP_SERVER --port $PORT_SERVER
" &
SERVER_PID=$!

echo "Aguardando servidor carregar o modelo..."
until curl -s -o /dev/null -w "%{http_code}" http://$IP_SERVER:$PORT_SERVER/v1/models | grep -q "200"; do
    echo "Servidor ainda inicializando..."
    sleep 60
done

# Roda o cliente Python apontando para o servidor com o venv ativado
echo "Executando cliente Python..."
"$VENV_DIR/bin/python3" <<EOF
import os
import openai

system_prompt = open(os.path.join("$PROMPT_SERVER")).read()

llm = openai.OpenAI(
    base_url="http://$IP_SERVER:$PORT_SERVER/v1",
    api_key="sk-no-key-required"
)

for user_prompt_file in os.listdir("$PROMPTS_USER_DIR"):
    user_prompt = open(os.path.join("$PROMPTS_USER_DIR", user_prompt_file)).read()
    
    out = llm.chat.completions.create(
        model="local-llama",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        max_tokens=None
    )
    
    base_name = os.path.splitext(user_prompt_file)[0]
    result_file_path = os.path.join("$RESULT_DIR", f"result_{base_name}.txt")
    with open(result_file_path, "w") as f:
        f.write(out.choices[0].message.content)
EOF

echo "Encerrando servidor..."
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

echo "Servidor finalizado. Resultado salvo em $RESULT_DIR."
echo "Script concluído com sucesso."
exit 0