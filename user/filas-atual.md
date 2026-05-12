# Filas

# OBS: FILAS AINDA NÃO IMPLEMENTADAS. TODOS OS NÓS ESTÃO NA FILA gorgonas DESCONSIDERAR o abaixo. Isso é apenas um planejamento para o futuro.

O cluster foi pensado para atender algumas demandas específicas como:
 - Preciso poder treinar meus modelos por vários dias, senão semanas.
 - Quero poder ter uma sessão interativa rapidamente para pequenos testes no meu código.
 - Não quero ter que esperar uma semana na fila porque alguém já alocou todas as máquinas e vai passar 15 dias treinando modelos

Para atender a todas as demandas acima o cluster é dividido em diferentes filas, cada uma com regras diferentes. No Slurm, uma fila é um conjunto de nós que obedecem a certas regras. Por exemplo, qual é o limite de tempo de alocação de um job para nós nessa fila. Assim, filas diferentes têm objetivos diferentes. É possível submeter um job em várias filas, sendo ele executado apenas uma vez, com os recursos da primeira fila disponível. Abaixo temos uma lista com todas as filas, seus recursos, suas regras e suas finalidades. Neste domumento não tem informações das configurações das máquinas. Para isso, ver [referencia de nós](user/nodes.md).

## Fila `gorgonas`
Recursos:
 - gorgona[3-7]

Regras:
 - **Limite de tempo**: infinito
 - **Limite de nós por alocação**: 4
 - **Limite de alocações por usuário**: infinito
 - **Uso compartilhado**: não

Finalidade:
 - Jobs com apenas 1 GPU
 - Jobs de tempo ilimitado

## Fila `gorgonas_dev`
Recursos:
 - gorgona[10]

Regras:
 - **Limite de tempo**: 30 minutos
 - **Limite de nós por alocação**: 1
 - **Limite de alocações por usuário**: 1
 - **Uso compartilhado**: sim
 - **Alocação default**: 1 CPU core + 2 GB memória, sem GPU

Finalidade:
 - Testes rápidos
 - Sessões interativas
 - Debugging
 - Uso apenas de CPU

## Fila `medusas_shr`
Recursos:
 - medusa[3-6]

Regras:
 - **Limite de tempo**: 2 dias
 - **Limite de nós por alocação**: 2
 - **Limite de nós por usuário**: 2
 - **Uso compartilhado**: sim
 - **Alocação default**: 1 CPU core + 1 GB memória, sem GPU

Finalidade:
 - Jobs que precisam de mais memória de GPU
 - Jobs que rodem em 2 GPUs
