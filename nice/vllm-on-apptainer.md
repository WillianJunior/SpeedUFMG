# Como Rodar o vLLM via Apptainer (Containers)

Essa é a forma mais trivial de se executar uma aplicação que manda requisições para um servidor vLLM.

Passos para realização:
- Fazer a build da imagem
- Colocar o seu workload
- Rodar...

## Montando a imagem

Como estamos usando containers precisamos da imagem a ser executada. O apptainer é interessante pois permite a execução de containers sem root. Porém subir serviços nas máquinas do cluster não é suportado, nem o objetivo do cluster. A geração da imagem é demorada e deve gerar um arquivo de ~10GB. Isso pode (e deve) ser feito da phocus4:

```command
username@phocus4:/sonic_home/username$ module avail
--------------------------- /opt/Modules/modulefiles ---------------------------
anaconda3.2023.09-0  cuda/11.8.0  cuda/12.8.0     python/3.12.1  
apptainer/1.4.2      cuda/12.3.2  python/3.7.6    uv/0.8.9       
cuda/11.1            cuda/12.6.2  python/3.10.12  

Key:
modulepath  
username@phocus4:/sonic_home/username$ module load apptainer/1.4.2
username@phocus4:/sonic_home/username$ apptainer build ./vllm.sif docker://vllm/vllm-openai
INFO:    Starting build...
INFO:    Fetching OCI image...
[...]
INFO:    Inserting Apptainer configuration...
INFO:    Creating SIF file...
INFO:    To see mksquashfs output with progress bar enable verbose logging
INFO:    Build complete: ./vllm.sif
username@phocus4:/sonic_home/username$
```

## Montando o seu workload

Uma forma de usar o vLLM de forma programática é por meio de sua interface offline. Abaixo temos um exemplo de como subir um modelo (você pode escolher o de sua preferência) e enviar requisições de inferência, imprimindo as respostas logo em seguida (você também pode mandar as suas requisições):

```python
# File: basic.py
# SPDX-License-Identifier: Apache-2.0
# From: https://git-ce.rwth-aachen.de/high-performance-computing/examples

from vllm import LLM, SamplingParams

# Sample prompts.
prompts = [
    "Hello, my name is",
    "The president of the United States is",
    "The capital of France is",
    "The future of AI is",
]
# Create a sampling params object.
sampling_params = SamplingParams(temperature=0.8, top_p=0.95)


def main():
    # Create an LLM.
    llm = LLM(model="facebook/opt-125m")
    # Generate texts from the prompts.
    # The output is a list of RequestOutput objects
    # that contain the prompt, generated text, and other information.
    outputs = llm.generate(prompts, sampling_params)
    # Print the outputs.
    print("\nGenerated Outputs:\n" + "-" * 60)
    for output in outputs:
        prompt = output.prompt
        generated_text = output.outputs[0].text
        print(f"Prompt:    {prompt!r}")
        print(f"Output:    {generated_text!r}")
        print("-" * 60)


if __name__ == "__main__":
    main()

```

## Rodando...

Com a imagem montada, podemos mandar um comando python para executar o código acima na imagem (arquivo basic.py). No exemplo abaixo estou abrindo uma sessão interativa para rodar o código (não esqueça de fechar a sessão ao fim via o comando 'exit' ou pelo atalho Ctrl+D):

```command
username@phocus4:/sonic_home/username$ srun --pty bash
username@gorgona7:/sonic_home/username$ apptainer exec -e --nv ./vllm.sif bash -c "python3 -W ignore basic.py"
INFO:    fuse2fs not found, will not be able to mount EXT3 filesystems
INFO:    gocryptfs not found, will not be able to use gocryptfs
INFO 09-16 16:22:08 [__init__.py:241] Automatically detected platform cuda.
INFO 09-16 16:22:12 [utils.py:326] non-default args: {'model': 'facebook/opt-125m', 'disable_log_stats': True}
INFO 09-16 16:22:37 [__init__.py:711] Resolved architecture: OPTForCausalLM
INFO 09-16 16:22:37 [__init__.py:1750] Using max model len 2048
[...]
(EngineCore_0 pid=2840) INFO 09-16 16:22:55 [core.py:214] init engine (profile, create kv cache, warmup model) took 8.51 seconds
INFO 09-16 16:22:56 [llm.py:298] Supported_tasks: ['generate']
Adding requests: 100%|████████████████████████████████████████████████| 4/4 [00:00<00:00, 227.28it/s]
Processed prompts: 100%|█| 4/4 [00:00<00:00, 11.09it/s, est. speed input: 72.15 toks/s, output: 166.5

Generated Outputs:
------------------------------------------------------------
Prompt:    'Hello, my name is'
Output:    " Dan, and I'm the owner of Nethics.org (My website"
------------------------------------------------------------
Prompt:    'The president of the United States is'
Output:    ' publicly wishing on the toilet.\n\n"Just as my country is all I'
------------------------------------------------------------
Prompt:    'The capital of France is'
Output:    ' probably still the worst country in the world. No one is going to care if'
------------------------------------------------------------
Prompt:    'The future of AI is'
Output:    ' right here\nIs this what you think it is?'
------------------------------------------------------------
username@gorgona7:/sonic_home/username$ exit
username@phocus4:/sonic_home/username$
```
