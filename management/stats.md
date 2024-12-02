# Uso do cluster por ano:
Campos:
 - Month: Data de contabilização. Contabilizado o uso do primeiro dia do mês corrente até o primeiro dia do mês seguinte.
 - Alloc.: Tempo gasto em alocações (jobs e sessões interativas).
 - Idle: Tempo livre sem uso.
 - Down: Tempo de máquinas fora da fila de execução por qualquer motivo (falha de nó, manutenção, testes, ...).
 - Reported: Quantidade de tempo observada no período. Sendo menos que 100% significa que o cluser inteiro (ou o nó HEAD) estava fora do ar.

## 2024
| Month | Alloc. | Idle   | Down   | Reported |
|-------|--------|--------|--------|----------|
| 01 | 3.19%  | 63.79% | 33.02% | 100.00%  |
| 02 | 14.19% | 69.43% | 16.38% | 100.00%  |
| 03 | 36.71% | 51.53% | 11.69% | 100.00%  |
| 04 | 35.52% | 47.43% | 16.81% | 100.00%  |
| 05 | 13.77% | 71.33% | 14.51% | 100.00%  |
| 06 | 10.89% | 77.78% | 11.11% | 100.00%  |
| 07 | 29.14% | 69.71% | 1.10%  | 100.00%  |
| 08 | 46.62% | 46.81% | 6.34%  | 100.00%  |
| 09 | 8.18%  | 86.45% | 5.23%  | 100.00%  |
| 10 | 27.28% | 71.66% | 0.95%  | 100.00%  |
| 11 | 25.04% | 73.67% | 0.98%  | 100.00%  |


## 2023
| Month | Alloc. | Idle   | Down   | Reported |
|-------|--------|--------|--------|----------|
| 10 | 0.23%  | 36.15% | 63.42% | 39.37%   |
| 11 | 3.86%  | 32.86% | 63.28% | 100.00%  |
| 12 | 2.10%  | 61.91% | 35.91% | 100.00%  |

# Script:

parâmetros: 
 - mbeg: mês de inicio
 - mend: mês de fim (inclusive o mês escrito)
 - ano: ...

```
mbeg=1; mend=6; ano=2024; format="allocated,idle,down,reported"; i=( 01 02 03 04 05 06 07 08 09 10 11 );j=( 02 03 04 05 06 07 08 09 10 11 12 ); echo "----------------- $ano -----------------"; echo -e "Month\tAlloc.\tIdle\tDown\tReported"; echo '----------------------------------------'; echo '----- -------- ------- ------- ---------'; for idx in $(seq $(($mbeg - 1)) $( if [ $mend -lt 12 ]; then echo $(($mend - 1)); else echo 10; fi ) ); do echo -n -e "${i[$idx]}-${j[$idx]}\t"; sreport cluster Utilization -t percent start=${ano}-${i[$idx]}-01 end=${ano}-${j[$idx]}-01 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; done; if [ $mend -eq 12 ]; then echo -n "12-01 "; sreport cluster Utilization -t percent start=${ano}-12-01 end=$((${ano}+1))-01-01 format=${format} | grep "%" | tr -s ' ' | awk '{$1=$1};1' | sed  's/ /\t/g'; fi; echo '----------------------------------------';
```
