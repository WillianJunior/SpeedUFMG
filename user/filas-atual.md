# Filas

O cluster foi pensado para atender algumas demandas específicas como:
 - Preciso poder treinar meus modelos por vários dias, senão semanas.
 - Quero poder ter uma sessão interativa rapidamente para pequenos testes no meu código.
 - Não quero ter que esperar uma semana na fila porque alguém já alocou todas as máquinas e vai passar 15 dias treinando modelos

Para atender a todas as demandas acima o cluster é dividido em diferentes filas, cada uma com regras diferentes. No Slurm, uma fila é um conjunto de nós que obedecem a certas regras. Por exemplo, qual é o limite de tempo de alocação de um job para nós nessa fila. Assim, filas diferentes têm objetivos diferentes. É possível submeter um job em várias filas, sendo ele executado apenas uma vez, com os recursos da primeira fila disponível. Abaixo temos uma lista com todas as filas, seus recursos, suas regras e suas finalidades:

# OBS: FILAS AINDA NÃO IMPLEMENTADAS. TODOS OS NÓS ESTÃO NA FILA gorgonas

## Fila gorg-long
Recursos:
 - gorgona[1-2]

Regras:
 - **Limite de tempo**: infinito
 - **Limite de nós por alocação**: 1
 - **Limite de alocações por usuário**: 1

Finalidade:
 - Jobs para montagem de modelos que demorem mais de 48 horas
 - Jobs via sbatch

## Fila gorg-std
Recursos:
 - gorgona[3-5]

Regras:
 - **Limite de tempo**: 48 horas
 - **Limite de nós por alocação**: sem limite
 - **Limite de alocações por usuário**: sem limite

Finalidade:
 - Jobs que não sejam tão longos
 - Experimentos já estáveis via sbatch

## Fila gorg-dev
Recursos:
 - gorgona[7,10]

Regras:
 - **Limite de tempo**: 2 horas
 - **Limite de nós por alocação**: 1
 - **Limite de alocações por usuário**: 1

Finalidade:
 - Jobs de compilação onde é necessário usar paralelismo (e.g., compilar um llvm ou openCV)
 - Sessões interativas para debugging de código ou testar uma primeira execução
