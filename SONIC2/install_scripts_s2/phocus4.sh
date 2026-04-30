# aprendizados:

# Limitar o uso de memória por usuário!!!
# Muitos usam o vscode. O vscode é muitio dispendioso com recursos e 
# tenta hoggar toda a memória. Pior: precisa fechar a conexão manualmente
# ou os recursos continuam alocados!!! Ninguém faz isso. Se não limitar, 
# pode acabar indo tudo para o swap e travar o sistema.

# Usuários do LDAP podem vir com outros shell, como o tcsh.
# Não tem como trocar isso da phocus4, nem com root, já que essa configuração
# está no LDAP, e não tenho acesso a ele.
# em /etc/sssd/sssd.conf adicionar para forçar o bash:
[nss]
override_shell = /bin/bash


