def fibonacci(n):
    # Caso base: se n for 0 ou 1, retorna n
    if n <= 1:
        return n
    else:
        # Chamada recursiva para calcular os dois números anteriores
        return fibonacci(n - 1) + fibonacci(n - 2)

# Exemplo de uso
numero = 10
print(f'O {numero}º número de Fibonacci é: {fibonacci(numero)}')
