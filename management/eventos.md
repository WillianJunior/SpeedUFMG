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

## 2026-10-09
**Evento:** `gorgona6` foi desligada na mão.

**Maquinas afetadas:** `gorgona6`

**Causa:** Pressionaram o botão de desligar a máquina.

<details> 
 
Oct 08 15:06:27.409633 gorgona6 systemd-logind[1319]: Power key pressed.
 
Oct 08 15:06:27.409646 gorgona6 systemd-logind[1319]: Powering Off...

Oct 08 15:06:27.619910 gorgona6 systemd-logind[1319]: System is powering down.

[...]

Oct 08 15:09:29.416658 gorgona6 systemd[1]: Finished System Power Off.

Oct 08 15:09:29.416740 gorgona6 systemd[1]: Reached target System Power Off.

Oct 08 15:09:29.416786 gorgona6 systemd[1]: Shutting down.

</details> 

**Resolução:** Máquina reiniciada.

**Obsservações:** Foi chamada a atenção dos usuários da sala 3222 no telegram.


## 2026-10-09
**Evento:** Uma das gpus da `medusa5` falhou.

**Maquinas afetadas:** `medusa5`

**Causa:** Falha de hardware:

<details> 
Oct  6 04:30:32 medusa5 kernel: ------------[ cut here ]------------

Oct  6 04:30:32 medusa5 kernel: WARNING: CPU: 3 PID: 27962 at /var/lib/dkms/nvidia/610.43.02/build/kernel-open/nvidia/nv.c:5410 nvidia_dev_put_uuid+0x48/0x50 [nvidia]

Oct  6 04:30:32 medusa5 kernel: Modules linked in: binfmt_misc rfcomm snd_seq_dummy snd_hrtimer rpcsec_gss_krb5 auth_rpcgss nfsv4 beegfs(OE) rdma_cm iw_cm dns_resolver ib_cm nfs ib_core lockd grace
 fscache netfs nft_fib_inet nft_fib_ipv4 nft_fib_ipv6 nft_fib nft_reject_inet nf_reject_ipv4 nf_reject_ipv6 nft_reject nft_ct nft_chain_nat nf_nat nf_conntrack nf_defrag_ipv6 nf_defrag_ipv4 nf_tabl
es nfnetlink qrtr bnep sunrpc vfat fat nvidia_uvm(OE) nvidia_drm(OE) nvidia_modeset(OE) nvidia(OE) mt7925e mt7925_common mt792x_lib snd_hda_codec_alc882 mt76_connac_lib snd_hda_codec_realtek_lib sn
d_hda_codec_nvhdmi snd_hda_codec_generic snd_hda_codec_hdmi mt76 snd_hda_intel amd_atl intel_rapl_msr mac80211 intel_rapl_common snd_hda_codec amd64_edac edac_mce_amd snd_hda_core btusb btrtl snd_i
ntel_dspcfg btintel snd_intel_sdw_acpi kvm_amd snd_hwdep btbcm snd_seq btmtk libarc4 snd_seq_device bluetooth drm_ttm_helper kvm cfg80211 snd_pcm ttm eeepc_wmi asus_wmi drm_client_lib snd_timer spa
rse_keymap rapl drm_kms_helper video wmi_bmof pcspkr snd rfkill

Oct  6 04:30:32 medusa5 kernel: i2c_piix4 soundcore k10temp i2c_smbus i2c_designware_platform gpio_amdpt gpio_generic i2c_designware_core drm xfs libcrc32c ahci libahci crct10dif_pclmul crc32_pclmu
l nvme crc32c_intel libata atlantic nvme_core igc ghash_clmulni_intel ccp nvme_keyring nvme_auth macsec sp5100_tco wmi dm_mirror dm_region_hash dm_log dm_mod i2c_dev fuse

Oct  6 04:30:32 medusa5 kernel: CPU: 3 PID: 27962 Comm: python Kdump: loaded Tainted: G           OE      ------  ---  5.14.0-687.26.1.el9_8.x86_64 #1

Oct  6 04:30:32 medusa5 kernel: Hardware name: ASUS System Product Name/Pro WS TRX50-SAGE WIFI, BIOS 1203 07/18/2025

Oct  6 04:30:32 medusa5 kernel: RIP: 0010:nvidia_dev_put_uuid+0x48/0x50 [nvidia]

Oct  6 04:30:32 medusa5 kernel: Code: 0e d5 ff ff 31 d2 48 89 de 48 89 ef e8 e1 32 14 00 85 c0 75 15 48 8d bb 40 07 00 00 5b 5d e9 7f 6c 42 c6 5b 5d e9 d3 b3 5c c6 <0f> 0b eb e7 0f 1f 40 00 90 90 9
0 90 90 90 90 90 90 90 90 90 90 90

Oct  6 04:30:32 medusa5 kernel: RSP: 0018:ff4ab5d9e568f8b0 EFLAGS: 00010202

Oct  6 04:30:32 medusa5 kernel: RAX: 0000000000000026 RBX: ff2f6e6468cc0000 RCX: ff4ab5d9e568f830

Oct  6 04:30:32 medusa5 kernel: RDX: 0000000000000000 RSI: 0000000000000286 RDI: ff4ab5d9e568f7f0

Oct  6 04:30:32 medusa5 kernel: RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000008

Oct  6 04:30:32 medusa5 kernel: R10: 0000000040000000 R11: ff2f6e64b0ad0000 R12: ff4ab5d9c2051058

Oct  6 04:30:32 medusa5 kernel: R13: ff2f6e6401666000 R14: ff4ab5d9c4a290a8 R15: ff4ab5d9c4a29038

Oct  6 04:30:32 medusa5 kernel: FS:  0000000000000000(0000) GS:ff2f6ea27cac0000(0000) knlGS:0000000000000000

Oct  6 04:30:32 medusa5 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033

Oct  6 04:30:32 medusa5 kernel: CR2: 00007f63d10836d8 CR3: 00000013bfa10004 CR4: 0000000000f71ef0

Oct  6 04:30:32 medusa5 kernel: PKRU: 55555554

Oct  6 04:30:32 medusa5 kernel: Call Trace:

Oct  6 04:30:32 medusa5 kernel: <TASK>

[...]

Oct  6 04:30:32 medusa5 kernel: ? do_syscall_64+0x6b/0xe0

Oct  6 04:30:32 medusa5 kernel: ? exc_page_fault+0x74/0x150

Oct  6 04:30:32 medusa5 kernel: entry_SYSCALL_64_after_hwframe+0x76/0x7e

Oct  6 04:30:32 medusa5 kernel: RIP: 0033:0x7f63d0d0fede

Oct  6 04:30:32 medusa5 kernel: Code: Unable to access opcode bytes at 0x7f63d0d0feb4.

Oct  6 04:30:32 medusa5 kernel: RSP: 002b:00007f6044bfe7c0 EFLAGS: 00000293 ORIG_RAX: 00000000000000e8

Oct  6 04:30:32 medusa5 kernel: RAX: fffffffffffffffc RBX: 00007f600fee73f0 RCX: 00007f63d0d0fede

Oct  6 04:30:32 medusa5 kernel: RDX: 0000000000000001 RSI: 00007f600fee73f0 RDI: 000000000000001a

Oct  6 04:30:32 medusa5 kernel: RBP: 0000000000000001 R08: 0000000000000000 R09: 0000000000000002

Oct  6 04:30:32 medusa5 kernel: R10: 00000000ffffffff R11: 0000000000000293 R12: 00007f6044bff5d0

Oct  6 04:30:32 medusa5 kernel: R13: ffffffffffffffff R14: 000000000c61c840 R15: 00007f6009347fb0

Oct  6 04:30:32 medusa5 kernel: </TASK>

Oct  6 04:30:32 medusa5 kernel: ---[ end trace 0000000000000000 ]---

[...]

Oct  6 04:30:32 medusa5 kernel: NVRM: kgmmuInvalidateTlb_GM107: TLB invalidation failed waiting for prior invalidate (status=0x0000000f), vaspaceFlags 0x4081081, scope 0x2, GFID 0

Oct  6 04:30:32 medusa5 kernel: NVRM: kgmmuInvalidateTlb_GM107: TLB invalidation failed waiting for prior invalidate (status=0x0000000f), vaspaceFlags 0x4081081, scope 0x2, GFID 0

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f for fn 10 sequence 24013!

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 rpcRmApiFree_GSP: GspRmFree failed: hClient=0xc1d00312; hObject=0x5c000037; paramsStatus=0x00000000; status=0x0000000f

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 nvAssertFailedNoLog: Assertion failed: (status == NV_OK) || (status == NV_ERR_GPU_IN_FULLCHIP_RESET) @ rs_client.c:844

Oct  6 04:30:32 medusa5 kernel: NVRM: nvAssertFailedNoLog: Assertion failed: (status == NV_OK) || (status == NV_ERR_GPU_IN_FULLCHIP_RESET) @ rs_server.c:259

Oct  6 04:30:32 medusa5 kernel: NVRM: nvAssertFailedNoLog: Assertion failed: (status == NV_OK) || (status == NV_ERR_GPU_IN_FULLCHIP_RESET) @ rs_server.c:1375

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f for fn 76 sequence 24068!

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 _deviceTeardown: Disable of Cuda limit activation failedNVRM: GPU0 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f for fn 10 sequence 24069!

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 rpcRmApiFree_GSP: GspRmFree failed: hClient=0xc1d00312; hObject=0x5c000002; paramsStatus=0x00000000; status=0x0000000f

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f for fn 10 sequence 24070!

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 rpcRmApiFree_GSP: GspRmFree failed: hClient=0xc1d00314; hObject=0xa55a0030; paramsStatus=0x00000000; status=0x0000000f

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 _issueRpcAndWait: rpcSendMessage failed with status 0x0000000f for fn 10 sequence 24071!

Oct  6 04:30:32 medusa5 kernel: NVRM: GPU0 rpcRmApiFree_GSP: GspRmFree failed: hClient=0xc1d00314; hObject=0xa55a0020; paramsStatus=0x00000000; status=0x0000000f

</details>

**Resolução:** Reboot.

**Obsservações:** Reboot via slurm falhou anteriormente. Tentou-se `sync && reboot -f now`. Mesmo problema de hanging, sendo necessário um hard reset.


## 2026-09-18
**Evento:** Uma das gpus da `medusa4` falhou.

**Maquinas afetadas:** `medusa4`

**Causa:** GPU caiu do bus. Falha de hardware.

**Resolução:** Reboot.

**Obsservações:** Reboot via slurm falhou. A `medusa4` permaneceu ligada sem reiniciar completamente. Precisou de um hard reset.

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
