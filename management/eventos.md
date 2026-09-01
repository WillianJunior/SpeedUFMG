Histórico de eventos com o cluster, e suas soluções

<!--
Padrão:
## AAAA-MM-DD
**Evento:** 

**Maquinas afetadas:** 

**Causa:** 

**Resolução:** 

**Obsservações:** 
-->

## 2026-09-01
**Evento:** Queda de luz no DCC.

**Maquinas afetadas:** `medusa3`

**Resolução:** `medusa3` precisou `mount -a` e reiniciar os serviços slurmd e beegfs-storage e beegfs-client.

**Obsservações:** Problema recorrente na falta de rede. TODO: organizar os serviços de mounting, slurmd, e beegfs para esperarem a rede estar pronta antes de iniciar. Não colocar isso como algo que para o boot (devo conseguir boot/ssh msm se não tiver iniciado esses serviços.)

## 2026-08-26
**Evento:** `snfs2` inacessível às `medusas`

**Maquinas afetadas:** `medusas` inicialmente, mas todas afetadas.

**Causa:** beegfs-client falhava nas `medusas` por um problema de rede não descrito. 

**Resolução:** 
 - Reboot das `medusas`.
 - Espera para a rede voltar a funcionar (às 10h não funcionava os serviços, às 12h30 voltou sem problemas).
 - Reinicialização dos serviços beegfs-storage e beegfs-client nas `medusas`.
 - Reinicialização do serviço beegfs-client nas `gorgonas`.
**Observações:** `phocus4` teve seu beegfs-client reiniciado automaticamente, mesmo após o reboot da `medusa4` (mgmt do beegfs), as demais máquinas não. Necessário alterar as dependências dos serviços systemd do beegfs-client para reiniciar sem parar quando houver rede.

## 2026-08-25
**Evento:** `gorgona6` inacessível

**Causa:** Cabo de rede desconectado dela e conectado na parede em loop.

**Resolução:** Cabo retornado. Alunos na sala avisados para não voltarem a mexer nessa máquina. Problema recorrente.

## 2026-08-24
**Evento:** Queda de energia.

**Maquinas afetadas:** `phocus4`, `tails1`, `sonik2`

**Causa:** Curto em outra máquina, resultando em queda do disjuntor.

**Resolução:** Dia 2026-08-25 foi religado o disjuntor. Sem problemas adicionais.
