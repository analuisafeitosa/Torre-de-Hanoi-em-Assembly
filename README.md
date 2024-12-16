# Torre de Hanoi em Assembly

Este documento descreve detalhadamente o funcionamento do código Assembly que implementa o jogo da Torre de Hanoi.

---
## Colaboradores
* Ana Luisa Feitosa
* Lucas dos Santos
---
## Como rodar o código
* Utilize um compilador online (https://www.tutorialspoint.com/compile_assembly_online.php)
* Execute o codigo presente no repositorio pelo emulador
* Verifique as saidas na tela 
---
## Visão Geral
O código apresenta uma implementação do problema da Torre de Hanoi em Assembly, utilizando chamadas recursivas para resolver o problema. Ele pede ao usuário o número de discos, valida a entrada e resolve o problema, exibindo os movimentos necessários para transferir os discos de uma torre para outra seguindo as regras do jogo.

---

## Estrutura do Código
### Seção `.text`
- Define o ponto de entrada (`_start`) e contém as funções para execução do programa.

### Seção `.data`
- Contém mensagens fixas e constantes para exibição ao usuário.

### Seção `.bss`
- Contém espaço reservado para variáveis dinâmicas, como a entrada do usuário.

---

## Passo a Passo do Código

### Entrada do Usuário
1. **Exibição do Menu**:
   - Usa `sys_write` para exibir a mensagem inicial pedindo ao usuário o número de discos.
2. **Recebimento da Entrada**:
   - Usa `sys_read` para capturar o valor digitado pelo usuário e o armazena no buffer `discos`.
3. **Conversão para Inteiro**:
   - Chama a função `stringparaint` para converter a string ASCII para um número inteiro.

### Validação da Entrada
- Verifica se o número está entre 1 e 9:
  - Se for inválido, exibe uma mensagem de erro (`msg_numero_errado`) e retorna ao início do processo.

### Função `torrehanoi`
- Implementa o algoritmo recursivo:
  1. **Caso Base**: Se o número de discos é 0, a função retorna imediatamente.
  2. **Chamada Recursiva 1**: Move `n-1` discos da torre de origem para a torre intermediária.
  3. **Mover Disco Atual**: Move o disco do topo da torre de origem para a torre de destino.
  4. **Chamada Recursiva 2**: Move os `n-1` discos da torre intermediária para a torre de destino.

### Função `imprime`
- Exibe os movimentos realizados pelo programa:
  - Atualiza os caracteres ASCII para representar os discos e torres.
  - Usa `sys_write` para exibir o movimento atual.

### Finalização
- Exibe uma mensagem de conclusão (`msg_concluido`) e retorna ao início do programa.

---

## Detalhamento Linha por Linha

### Bloco `_start`
1. **Configura o registrador base da pilha**:
   ```asm
   push ebp
   mov ebp, esp
   ```
   - Salva o ponteiro base da pilha e prepara o espaço de execução.

2. **Exibição do menu**:
   ```asm
   mov edx, len_menu
   mov ecx, menu
   mov ebx, 1
   mov eax, 4
   int 0x80
   ```
   - Configura os parâmetros para a chamada de escrita e exibe a mensagem inicial.

3. **Leitura da entrada do usuário**:
   ```asm
   mov edx, 5
   mov ecx, discos
   mov ebx, 0
   mov eax, 3
   int 0x80
   ```
   - Configura os parâmetros para a chamada de leitura e armazena a entrada no buffer `discos`.

4. **Conversão da string para inteiro**:
   ```asm
   mov edx, discos
   call stringparaint
   ```
   - Chama a função que converte o valor ASCII em inteiro.

5. **Validação do número**:
   ```asm
   cmp eax, 1
   jl numero_invalido
   cmp eax, 9
   jg numero_invalido
   ```
   - Compara o valor para garantir que está no intervalo permitido (1-9).

6. **Chamada da função principal**:
   ```asm
   push dword 0x2
   push dword 0x3
   push dword 0x1
   push eax
   call torrehanoi
   ```
   - Passa os parâmetros (número de discos e torres) e chama a função `torrehanoi`.

### Função `stringparaint`
- Converte caractere por caractere de ASCII para inteiro.
```asm
.conversao_loop:
    movzx ecx, byte [edx]
    inc edx
    cmp ecx, '0'
    jb .conversao_fim
    cmp ecx, '9'
    ja .conversao_fim
    sub ecx, '0'
    imul eax, ebx
    add eax, ecx
    jmp .conversao_loop
.conversao_fim:
    ret
```
- O loop processa cada caractere da string, converte para um dígito e acumula o valor em `eax`.

### Função `torrehanoi`
- Implementa o algoritmo recursivo da Torre de Hanoi.
```asm
cmp eax, 0x0
jle .retornar
```
- Verifica o caso base (0 discos) e retorna se for verdadeiro.

```asm
push dword [ebp+16]
push dword [ebp+20]
push dword [ebp+12]
push dword eax
call torrehanoi
```
- Primeira chamada recursiva para mover `n-1` discos.

```asm
push dword [ebp+16]
push dword [ebp+12]
push dword [ebp+8]
call imprime
```
- Move o disco atual e exibe o movimento.

```asm
push dword [ebp+12]
push dword [ebp+16]
push dword [ebp+20]
mov eax, [ebp+8]
dec eax
push dword eax
call torrehanoi
```
- Segunda chamada recursiva para mover `n-1` discos.

### Função `imprime`
- Atualiza e exibe o movimento do disco.
```asm
mov eax, [ebp + 8]
add al, 48
mov [disco], al
mov eax, [ebp + 12]
add al, 64
mov [torre_origem], al
mov eax, [ebp + 16]
add al, 64
mov [torre_destino], al
```
- Converte os valores numéricos para ASCII antes de exibir.

---

