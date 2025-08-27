#!/bin/bash

get_ip() {
    local node=$1
    srun --nodes=1 --nodelist=$node hostname -I | awk '{print $1}'
}

echo "Nós alocados pelo SLURM: $SLURM_NODELIST"
ALLOCATED_NODES=($(scontrol show hostnames $SLURM_NODELIST))

if [ ${#ALLOCATED_NODES[@]} -lt 3 ]; then
    echo "Erro: Menos de 3 nós foram alocados."
    exit 1
fi


RPC1_HOSTNAME=${ALLOCATED_NODES[0]}
RPC2_HOSTNAME=${ALLOCATED_NODES[1]}
SERVER_HOSTNAME=${ALLOCATED_NODES[2]}
echo "RPC1 será executado em: $RPC1_HOSTNAME"
echo "RPC2 será executado em: $RPC2_HOSTNAME"
echo "SERVER será executado em: $SERVER_HOSTNAME"

# Obtém os IPs correspondentes aos nós
IP_RPC1=$(get_ip "$RPC1_HOSTNAME")
IP_RPC2=$(get_ip "$RPC2_HOSTNAME")
IP_SERVER=$(get_ip "$SERVER_HOSTNAME")
if [[ -z "$IP_RPC1" || -z "$IP_RPC2" || -z "$IP_SERVER" ]]; then
    echo "Erro: Um ou mais IPs não foram resolvidos corretamente."
    echo "RPC1_HOSTNAME: $RPC1_HOSTNAME -> IP_RPC1: $IP_RPC1"
    echo "RPC2_HOSTNAME: $RPC2_HOSTNAME -> IP_RPC2: $IP_RPC2"
    echo "SERVER_HOSTNAME: $SERVER_HOSTNAME -> IP_SERVER: $IP_SERVER"
    exit 1
fi

# Inicia os servidores RPC nos nós correspondentes em background
echo "Iniciando servidor RPC1 em $RPC1_HOSTNAME..."
srun --nodes=1 --nodelist=$RPC1_HOSTNAME --partition=gorgonas bash -c "
cd $DIR_LLAMA_SCRIPT
./rpc-server -H $IP_RPC1 -p $PORT_RPC
" &
RPC1_PID=$!

echo "Iniciando servidor RPC2 em $RPC2_HOSTNAME..."
srun --nodes=1 --nodelist=$RPC2_HOSTNAME --partition=gorgonas bash -c "
cd $DIR_LLAMA_SCRIPT
./rpc-server -H $IP_RPC2 -p $PORT_RPC
" &
RPC2_PID=$!

until nc -z $IP_RPC1 $PORT_RPC && nc -z $IP_RPC2 $PORT_RPC; do
    echo "RPCs ainda não prontos..."
    sleep 5
done

echo "Iniciando servidor Llama em $SERVER_HOSTNAME..."
srun --nodes=1 --nodelist=$SERVER_HOSTNAME --partition=gorgonas bash -c "
cd $DIR_LLAMA_SCRIPT
./llama-server -m $MODEL -c 8192 -ngl 99 --rpc $IP_RPC1:$PORT_RPC,$IP_RPC2:$PORT_RPC --host $IP_SERVER --port $PORT_SERVER
" &
SERVER_PID=$!

echo "Aguardando servidor carregar o modelo..."
until curl -s -o /dev/null -w "%{http_code}" http://$IP_SERVER:$PORT_SERVER/v1/models | grep -q "200"; do
    echo "Servidor ainda inicializando..."
    sleep 180
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

echo "Encerrando RPCs..."
kill $RPC1_PID 2>/dev/null || true
kill $RPC2_PID 2>/dev/null || true
wait $RPC1_PID 2>/dev/null || true
wait $RPC2_PID 2>/dev/null || true

echo "Todos os servidores foram encerrados com sucesso."
echo "Resultado salvo em $RESULT_DIR."
echo "Script concluído com sucesso."
exit 0