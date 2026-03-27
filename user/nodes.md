# Referência de Máquinas

| Nome            | Partição      | CPU                               | Mem    | GPU               |
|-----------------|---------------|-----------------------------------|--------|-------------------|
| gorgona[3-4]    | gorgonas      | Ryzen 9 5950X 16-Core             | 64 GB  | RTX 4090 24GB     |
| gorgona[5-7,10] | gorgonas      | Ryzen 9 5950X 16-Core             | 64 GB  | RTX 3090 Ti 24GB  |
| gorgona[5-7,10] | gorgonas_dev  | Ryzen 9 5950X 16-Core             | 64 GB  | RTX 3090 Ti 24GB  |
| medusa[4,6]     | medusas       | Ryzen Threadripper 7970X 32-Cores | 250 GB | 2x RTX 5090 32 GB |
| medusa[5]       | medusas_shr   | Ryzen Threadripper 7970X 32-Cores | 250 GB | 2x RTX 5090 32 GB |

# Politicas de Partições

## `gorgonas`
 - Nós para uso geral.
 - Alocação exclusiva e total (todos CPU cores, memória e GPU).
 - Tempo de uso ilimitado.

## `gorgonas_dev`
 - Nós para fins de debug/dev.
 - Alocação máxima de 30 minutos para permitir uso rápido
 - Alocação compartilhada, podendo alocar ou não a GPU, e definir o número de CPU cores necessários.

## `medusas`
 - Nós pesados de 2 GPUs.
 - Alocação exclusiva e total (todos CPU cores, memória e GPU).
 - Tempo de uso limitado a 2 dias para evitar *hogging*, mas pode ser revisto.

## `medusas_shr`
 - Nós pesados de 2 GPUs.
 - Uso parcial permitido, e.g., 50% dos recursos (1 GPU e 50% dos cores e memória por job) ou completo (todas GPUs, cores e memória).
 - Teste para permitir que jobs que necessitem apenas de uma GPU com 32 GB de VRAM rodem sem deixar a outra GPU ociosa.

# Histórico de Mudanças no Cluster

## 21/03/2026
 - Criada partição `medusas_shr` com `medusa5` para testes.
 - Permitida a execução de 2 jobs ao mesmo tempo, cada um com uma GPU e 50% dos recrusos de CPU/memória.

## 07/03/2026
 - `medusa[4,6]` adicionadas ao slurm como compute, uso exclusivo apenas.

## 28/02/2026
 - Novo storage: `/snfs2` como BeeGFS usando as `medusas[4-6]`

## 20/02/2026
 - `medusa5` adicionada ao slurm como compute.
 - Uso exclusivo apenas.

## 01/01/2026
 - Init
 - Temos compute `gorgona[3-7,10]`
 - Temos storage `tails1` com `/sonic_*` e `sonik2` com `/snfs1`.
