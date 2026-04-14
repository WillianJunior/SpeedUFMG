```command
willianjunior@phocus4:/sonic_home/willianjunior$ salloc -pmedusas -t 8:00:00
willianjunior@phocus4:/sonic_home/willianjunior$ ssh medusa4
[willianjunior@medusa4 ~]$ module load python/3.12.1 uv
[willianjunior@medusa4 ~]$ uv venv ./vllm-env
[willianjunior@medusa4 ~]$ source vllm-env/bin/activate
(vllm-env) [willianjunior@medusa4 ~]$ pip3 install vllm

```
