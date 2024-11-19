section .text

    global _start

; Main entry point
_start:
    ; Inicia o código
    push ebp                ; Salva o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha com esp

pedir_numero:
    ; Exibe a mensagem pedindo a quantidade de discos
    mov edx, len_menu       ; Carrega o comprimento da mensagem
    mov ecx, menu           ; Carrega o endereço da mensagem
    mov ebx, 1              ; Saída padrão (stdout)
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    ; Recebe o número de discos
    mov edx, 5              ; Limite de entrada (5 caracteres)
    mov ecx, discos         ; Armazena a entrada em 'discos'
    mov ebx, 0              ; Entrada padrão (stdin)
    mov eax, 3              ; Syscall para input
    int 0x80                ; Chama a interrupção para capturar entrada

    ; Converte o número de discos de string para inteiro
    mov edx, discos
    call stringparaint

    ; Verifica se o número é válido
    cmp eax, 1              ; Se menor que 1, número inválido
    jl numero_errado
    cmp eax, 9              ; Se maior que 9, número inválido
    jg numero_errado

    ; Prepara os parâmetros para chamar a função de Torre de Hanoi
    push dword 0x2          ; Meio
    push dword 0x3          ; Destino
    push dword 0x1          ; Origem
    push eax                ; Número de discos na pilha
    call torrehanoi         ; Chama a função Torre de Hanoi

    ; Finaliza o programa
    jmp fim_programa

numero_errado:
    ; Exibe a mensagem de erro
    mov edx, len_numero_errado
    mov ecx, msg_numero_errado
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir
    jmp pedir_numero        ; Volta para pedir o número novamente

fim_programa:
    ; Mensagem de conclusão
    mov edx, len_concluido
    mov ecx, msg_concluido
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    ; Finaliza o programa
    mov eax, 1              ; Syscall para exit
    mov ebx, 0              ; Código de saída
    int 0x80                ; Chama a interrupção para sair

stringparaint:
    xor eax, eax            ; Limpa o registrador eax
    mov ebx, 10             ; Base 10 para conversão

.loop:
    movzx ecx, byte [edx]   ; Carrega o próximo byte (dígito)
    inc edx                 ; Avança o ponteiro para o próximo byte
    cmp ecx, '0'            ; Verifica se o caractere é um dígito válido
    jb .done                ; Se não for, termina a conversão
    cmp ecx, '9'            ; Verifica se o caractere é um dígito válido
    ja .done                ; Se não for, termina a conversão

    sub ecx, '0'            ; Converte de ASCII para número
    imul eax, ebx           ; Multiplica o acumulador por 10
    add eax, ecx            ; Adiciona o dígito ao acumulador
    jmp .loop               ; Repete o loop até terminar

.done:
    ret                     ; Retorna da função

torrehanoi:
    push ebp                ; Salva o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha

    mov eax, [ebp+8]        ; Número de discos
    cmp eax, 0              ; Verifica se o número de discos é 0
    jle fim                 ; Se for 0, encerra a função

    ; Chamada recursiva - move o disco
    dec eax                 ; Decrementa o número de discos
    push dword [ebp+16]     ; Pino de trabalho
    push dword [ebp+20]     ; Pino de destino
    push dword [ebp+12]     ; Pino de origem
    push dword eax          ; Número de discos restantes
    call torrehanoi         ; Chama recursivamente

    ; Move o disco
    add esp, 12             ; Limpa a pilha
    push dword [ebp+16]     ; Pino de origem
    push dword [ebp+12]     ; Pino de origem
    push dword [ebp+8]      ; Número de discos
    call imprime            ; Chama a função para imprimir o movimento

    ; Recursão - move o disco para o pino de destino
    add esp, 12             ; Limpa a pilha
    push dword [ebp+12]     ; Pino de origem
    push dword [ebp+16]     ; Pino de trabalho
    push dword [ebp+20]     ; Pino de destino
    mov eax, [ebp+8]        ; Número de discos restantes
    dec eax                 ; Decrementa o número de discos
    push dword eax          ; Número de discos restantes
    call torrehanoi         ; Chama recursivamente

fim:
    mov esp, ebp            ; Restaura o ponteiro de pilha
    pop ebp                 ; Restaura o valor de ebp
    ret                     ; Retorna da função

imprime:
    push ebp                ; Empilha o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha

    ; Converte e imprime o disco
    mov eax, [ebp+8]        ; Disco a ser movido
    add al, 48              ; Converte para ASCII
    mov [disco], al         ; Armazena o valor do disco

    ; Converte e imprime o pino de origem
    mov eax, [ebp+12]       ; Pino de origem
    add al, 64              ; Converte para ASCII
    mov [torre_origem], al  ; Armazena o valor do pino de origem

    ; Converte e imprime o pino de destino
    mov eax, [ebp+16]       ; Pino de destino
    add al, 64              ; Converte para ASCII
    mov [torre_destino], al ; Armazena o valor do pino de destino

    ; Exibe a mensagem
    mov edx, len_msg_pino
    mov ecx, msg_pino
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    mov esp, ebp            ; Restaura o ponteiro de pilha
    pop ebp                 ; Restaura o valor de ebp
    ret                     ; Retorna da função

section .data
    menu db 'Seja bem vindo a jogo Torre de Hanoi! Digite a quantidade de discos: ', 0xa
    len_menu equ $-menu
    msg_concluido db 'A Torre de Hanoi foi finalizada com sucesso!', 0xa
    len_concluido equ $-msg_concluido
    msg_numero_errado db 'Número errado! Digite um número entre 1 e 9.', 0xa
    len_numero_errado equ $-msg_numero_errado
    msg_pino db 'Mova o disco ', 0
    disco db ' ', 0
    torre_origem db ' da torre', 0
    torre_destino db ' para torre', 0xa
    len_msg_pino equ $-msg_pino

section .bss
    discos resb 5
section .text

    global _start

; Main entry point
_start:
    ; Inicia o código
    push ebp                ; Salva o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha com esp

pedir_numero:
    ; Exibe a mensagem pedindo a quantidade de discos
    mov edx, len_menu       ; Carrega o comprimento da mensagem
    mov ecx, menu           ; Carrega o endereço da mensagem
    mov ebx, 1              ; Saída padrão (stdout)
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    ; Recebe o número de discos
    mov edx, 5              ; Limite de entrada (5 caracteres)
    mov ecx, discos         ; Armazena a entrada em 'discos'
    mov ebx, 0              ; Entrada padrão (stdin)
    mov eax, 3              ; Syscall para input
    int 0x80                ; Chama a interrupção para capturar entrada

    ; Converte o número de discos de string para inteiro
    mov edx, discos
    call stringparaint

    ; Verifica se o número é válido
    cmp eax, 1              ; Se menor que 1, número inválido
    jl numero_errado
    cmp eax, 9              ; Se maior que 9, número inválido
    jg numero_errado

    ; Prepara os parâmetros para chamar a função de Torre de Hanoi
    push dword 0x2          ; Meio
    push dword 0x3          ; Destino
    push dword 0x1          ; Origem
    push eax                ; Número de discos na pilha
    call torrehanoi         ; Chama a função Torre de Hanoi

    ; Finaliza o programa
    jmp fim_programa

numero_errado:
    ; Exibe a mensagem de erro
    mov edx, len_numero_errado
    mov ecx, msg_numero_errado
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir
    jmp pedir_numero        ; Volta para pedir o número novamente

fim_programa:
    ; Mensagem de conclusão
    mov edx, len_concluido
    mov ecx, msg_concluido
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    ; Finaliza o programa
    mov eax, 1              ; Syscall para exit
    mov ebx, 0              ; Código de saída
    int 0x80                ; Chama a interrupção para sair

stringparaint:
    xor eax, eax            ; Limpa o registrador eax
    mov ebx, 10             ; Base 10 para conversão

.loop:
    movzx ecx, byte [edx]   ; Carrega o próximo byte (dígito)
    inc edx                 ; Avança o ponteiro para o próximo byte
    cmp ecx, '0'            ; Verifica se o caractere é um dígito válido
    jb .done                ; Se não for, termina a conversão
    cmp ecx, '9'            ; Verifica se o caractere é um dígito válido
    ja .done                ; Se não for, termina a conversão

    sub ecx, '0'            ; Converte de ASCII para número
    imul eax, ebx           ; Multiplica o acumulador por 10
    add eax, ecx            ; Adiciona o dígito ao acumulador
    jmp .loop               ; Repete o loop até terminar

.done:
    ret                     ; Retorna da função

torrehanoi:
    push ebp                ; Salva o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha

    mov eax, [ebp+8]        ; Número de discos
    cmp eax, 0              ; Verifica se o número de discos é 0
    jle fim                 ; Se for 0, encerra a função

    ; Chamada recursiva - move o disco
    dec eax                 ; Decrementa o número de discos
    push dword [ebp+16]     ; Pino de trabalho
    push dword [ebp+20]     ; Pino de destino
    push dword [ebp+12]     ; Pino de origem
    push dword eax          ; Número de discos restantes
    call torrehanoi         ; Chama recursivamente

    ; Move o disco
    add esp, 12             ; Limpa a pilha
    push dword [ebp+16]     ; Pino de origem
    push dword [ebp+12]     ; Pino de origem
    push dword [ebp+8]      ; Número de discos
    call imprime            ; Chama a função para imprimir o movimento

    ; Recursão - move o disco para o pino de destino
    add esp, 12             ; Limpa a pilha
    push dword [ebp+12]     ; Pino de origem
    push dword [ebp+16]     ; Pino de trabalho
    push dword [ebp+20]     ; Pino de destino
    mov eax, [ebp+8]        ; Número de discos restantes
    dec eax                 ; Decrementa o número de discos
    push dword eax          ; Número de discos restantes
    call torrehanoi         ; Chama recursivamente

fim:
    mov esp, ebp            ; Restaura o ponteiro de pilha
    pop ebp                 ; Restaura o valor de ebp
    ret                     ; Retorna da função

imprime:
    push ebp                ; Empilha o valor de ebp
    mov ebp, esp            ; Estabelece a base da pilha

    ; Converte e imprime o disco
    mov eax, [ebp+8]        ; Disco a ser movido
    add al, 48              ; Converte para ASCII
    mov [disco], al         ; Armazena o valor do disco

    ; Converte e imprime o pino de origem
    mov eax, [ebp+12]       ; Pino de origem
    add al, 64              ; Converte para ASCII
    mov [torre_origem], al  ; Armazena o valor do pino de origem

    ; Converte e imprime o pino de destino
    mov eax, [ebp+16]       ; Pino de destino
    add al, 64              ; Converte para ASCII
    mov [torre_destino], al ; Armazena o valor do pino de destino

    ; Exibe a mensagem
    mov edx, len_msg_pino
    mov ecx, msg_pino
    mov ebx, 1              ; Saída padrão
    mov eax, 4              ; Syscall para output
    int 0x80                ; Chama a interrupção para imprimir

    mov esp, ebp            ; Restaura o ponteiro de pilha
    pop ebp                 ; Restaura o valor de ebp
    ret                     ; Retorna da função

section .data
    menu db 'Seja bem vindo a jogo Torre de Hanoi! Digite a quantidade de discos: ', 0xa
    len_menu equ $-menu
    msg_concluido db 'A Torre de Hanoi foi finalizada com sucesso!', 0xa
    len_concluido equ $-msg_concluido
    msg_numero_errado db 'Número errado! Digite um número entre 1 e 9.', 0xa
    len_numero_errado equ $-msg_numero_errado
    msg_pino db 'Mova o disco ', 0
    disco db ' ', 0
    torre_origem db ' da torre', 0
    torre_destino db ' para torre', 0xa
    len_msg_pino equ $-msg_pino

section .bss
    discos resb 5
