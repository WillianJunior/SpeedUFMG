# Uso do cluster por ano:
Campos:
 - Month: Data de contabilização. Contabilizado o uso do primeiro dia do mês corrente até o primeiro dia do mês seguinte.
 - Alloc.: Tempo gasto em alocações (jobs e sessões interativas).
 - Idle: Tempo livre sem uso.
 - Down: Tempo de máquinas fora da fila de execução por qualquer motivo (falha de nó, manutenção, testes, ...).
 - Reported: Quantidade de tempo observada no período. Sendo menos que 100% significa que o cluser inteiro (ou o nó HEAD) estava fora do ar.

## 2025
| Month | Alloc. | Idle   | Down   | Reported |
|-------|--------|--------|--------|----------|
|04|31.17%|66.98%|1.77%|94.09%|
|03|29.37%|69.58%|0.99%|100.00%|
|02|27.38%|68.51%|4.10%|100.00%|
|01|18.96%|53.38%|24.61%|100.16%|


## 2024
| Month | Alloc. | Idle   | Down   | Reported |
|-------|--------|--------|--------|----------|
|12|12.01%|77.22%|10.77%|100.00%|
|11|24.98%|73.73%|0.98%|100.00%|
|10|27.40%|71.50%|0.98%|100.00%|
|09|8.18%|86.45%|5.23%|100.00%|
|08|37.06%|55.69%|6.55%|100.00%|
|07|29.66%|69.14%|1.13%|100.00%|
|06|10.89%|77.78%|11.11%|100.00%|
|05|14.23%|70.37%|15.00%|100.00%|
|04|35.52%|47.43%|16.81%|100.00%|
|03|36.75%|51.52%|11.66%|100.00%|
|02|14.59%|68.32%|17.08%|100.00%|
|01|2.70%|63.75%|33.55%|100.00%|


## 2023
| Month | Alloc. | Idle   | Down   | Reported |
|-------|--------|--------|--------|----------|
| 12 | 2.10%  | 61.91% | 35.91% | 100.00%  |
| 11 | 3.86%  | 32.86% | 63.28% | 100.00%  |
| 10 | 0.23%  | 36.15% | 63.42% | 39.37%   |

# Script:

parâmetros: 
 - mbeg: mês de inicio
 - mend: mês de fim (inclusive o mês escrito)
 - ano: ...

Pretty
```
mbeg=1; mend=12; ano=2024; format="allocated,idle,down,reported"; i=( 01 02 03 04 05 06 07 08 09 10 11 12 ); echo "----------------- $ano -----------------"; echo -e "Month\tAlloc.\tIdle\tDown\tReported"; echo '----------------------------------------'; echo '----- -------- ------- ------- ---------'; for idx in $(seq $(($mend - 1)) -1 $(($mbeg - 1))); do echo -n -e "${i[$idx]}\t"; sreport cluster Utilization -t percent start=${ano}-${i[$idx]}-01 end=${ano}-${i[$idx]}-31 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; done; echo '----------------------------------------';
```

Table
```
mbeg=1; mend=12; ano=2024; format="allocated,idle,down,reported"; i=( 01 02 03 04 05 06 07 08 09 10 11 12 ); echo "## $ano"; echo "| Month | Alloc. | Idle   | Down   | Reported |"; echo '|-------|--------|--------|--------|----------|'; for idx in $(seq $(($mend - 1)) -1 $(($mbeg - 1))); do echo -n -e "|${i[$idx]}|"; sreport cluster Utilization -p -t percent start=${ano}-${i[$idx]}-01 end=${ano}-${i[$idx]}-31 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; done;
```
