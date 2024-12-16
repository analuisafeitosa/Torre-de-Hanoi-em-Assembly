section .text

global _start                        

; Ponto de entrada principal
_start:
    ; Prepara o registrador base da pilha
    push ebp                        
    mov ebp, esp                    

pedir_numero:
    ; Solicitar ao usuário um número de discos
    ; Exibe a mensagem inicial
    mov edx, len_menu                ; Tamanho da mensagem
    mov ecx, menu                    ; Endereço da mensagem
    mov ebx, 1                       ; Saída padrão (stdout)
    mov eax, 4                       ; Chamada de escrita (sys_write)
    int 0x80                        

    ; Recebe a entrada do usuário
    mov edx, 5                       ; Tamanho máximo de entrada
    mov ecx, discos                  ; Buffer para armazenar a entrada
    mov ebx, 0                       ; Entrada padrão (stdin)
    mov eax, 3                       ; Chamada de leitura (sys_read)
    int 0x80                        

    mov edx, discos                  ; Ponteiro para a string
    call stringparaint               ; Converte string para inteiro

    ; Valida o número fornecido
    cmp eax, 1                       ; Verifica se o número >= 1
    jl numero_invalido               ; Se for menor, exibe erro
    cmp eax, 9                       ; Verifica se o número <= 9
    jg numero_invalido               ; Se for maior, exibe erro

    ; Configura os parâmetros para a função torrehanoi
    push dword 0x2                   ; Torre intermediária
    push dword 0x3                   ; Torre de destino
    push dword 0x1                   ; Torre de origem
    push eax                         ; Quantidade de discos
    call torrehanoi                  ; Chama a função principal

    jmp finalizar                    ; Salta para finalizar

numero_invalido:
    ; Exibir mensagem de erro e pedir novamente
    mov edx, len_numero_errado       ; Tamanho da mensagem de erro
    mov ecx, msg_numero_errado       ; Ponteiro para a mensagem
    mov ebx, 1                       ; Saída padrão
    mov eax, 4                       ; Chamada sys_write
    int 0x80                         
    jmp pedir_numero                 ; Recomeça o loop

finalizar:
    ; Mensagem final e encerramento
    mov edx, len_concluido           ; Tamanho da mensagem final
    mov ecx, msg_concluido           ; Ponteiro para a mensagem
    mov ebx, 1                       ; Saída padrão
    mov eax, 4                       ; Chamada sys_write
    int 0x80                         
    jmp reiniciar                    ; Salta para reiniciar

reiniciar:
    jmp pedir_numero                 ; Reinicia o programa

stringparaint:
    ; Função para converter string ASCII em inteiro
    xor eax, eax                    ; Limpa o acumulador
    mov ebx, 10                     ; Base decimal
.conversao_loop:
    movzx ecx, byte [edx]           ; Carrega o byte atual
    inc edx                         ; Avança o ponteiro
    cmp ecx, '0'                    ; Verifica se >= '0'
    jb .conversao_fim               ; Sai do loop se menor
    cmp ecx, '9'                    ; Verifica se <= '9'
    ja .conversao_fim               ; Sai do loop se maior
    sub ecx, '0'                    ; Converte ASCII para dígito numérico
    imul eax, ebx                   ; Multiplica acumulador pela base
    add eax, ecx                    ; Soma o dígito atual
    jmp .conversao_loop             ; Continua o loop
.conversao_fim:
    ret                             ; Retorna

; Algoritmo da Torre de Hanoi
; Parâmetros:
; [ebp+8] = quantidade de discos
; [ebp+12] = torre origem
; [ebp+16] = torre intermediária
; [ebp+20] = torre destino
torrehanoi:
    push ebp                        ; Salva o ponteiro base
    mov ebp, esp                    
    mov eax, [ebp+8]                ; Carrega a quantidade de discos
    cmp eax, 0x0                    ; Verifica se é zero
    jle .retornar                   ; Se zero, termina a recursão

    ; Primeira chamada recursiva
    dec eax                         ; Decrementa o número de discos
    push dword [ebp+16]             ; Torre intermediária
    push dword [ebp+20]             ; Torre destino
    push dword [ebp+12]             ; Torre origem
    push dword eax                  ; Número de discos - 1
    call torrehanoi

    ; Move o disco atual
    add esp, 12                     ; Libera espaço da pilha
    push dword [ebp+16]             ; Torre destino
    push dword [ebp+12]             ; Torre origem
    push dword [ebp+8]              ; Número do disco atual
    call imprime                    ; Exibe o movimento

    ; Segunda chamada recursiva
    add esp, 12                     ; Libera espaço da pilha
    push dword [ebp+12]             ; Torre origem
    push dword [ebp+16]             ; Torre intermediária
    push dword [ebp+20]             ; Torre destino
    mov eax, [ebp+8]                
    dec eax                         ; Decrementa o número de discos
    push dword eax
    call torrehanoi
.retornar:
    mov esp, ebp                    ; Restaura ponteiro da pilha
    pop ebp                         ; Restaura o valor base
    ret                             ; Retorna

imprime:
    ; Função para exibir movimentos
    push ebp                        ; Salva o ponteiro base
    mov ebp, esp                    
    ; Configura os valores para exibição
    mov eax, [ebp + 8]              ; Disco a ser movido
    add al, 48                      ; Converte para ASCII
    mov [disco], al                 
    mov eax, [ebp + 12]             ; Torre origem
    add al, 64                      ; Converte para ASCII
    mov [torre_origem], al          
    mov eax, [ebp + 16]             ; Torre destino
    add al, 64                      ; Converte para ASCII
    mov [torre_destino], al         
    ; Exibe a mensagem de movimento
    mov edx, len_msg_pino           ; Tamanho da mensagem
    mov ecx, msg_pino               ; Ponteiro para mensagem
    mov ebx, 1                      ; Saída padrão
    mov eax, 4                      ; Chamada sys_write
    int 0x80                        
    mov esp, ebp                    ; Restaura ponteiro da pilha
    pop ebp                         ; Restaura valor base
    ret                             ; Retorna

section .data
menu db 'Bem-vindo ao Jogo da Torre de Hanoi! Informe a quantidade de discos (1-9): ', 0xa
len_menu equ $-menu

msg_concluido db 'Parabéns! Você completou a Torre de Hanoi!', 0xa
len_concluido equ $-msg_concluido

msg_numero_errado db 'Entrada inválida! Informe um número entre 1 e 9.', 0xa
len_numero_errado equ $-msg_numero_errado

msg_pino:
    db 'Mover o disco ',
    disco db ' ',
    db ' da torre ',
    torre_origem db ' ',
    db ' para torre ',
    torre_destino db ' ', 0xa
len_msg_pino equ $-msg_pino

section .bss
discos resb 5                      ; Buffer para entrada do usuário