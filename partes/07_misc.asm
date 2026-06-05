; ===================================================================
; Delay: Pausa a execucao por uma fracao de segundo
; Sugestao de responsavel: Lucca
; ===================================================================
Delay:
    push r0
    push r1
    push r2
    loadn r0,#100
    loadn r1,#5
    loadn r2,#1
    LoopDelay:
        sub r0,r0,r2 ;Subtrai 1 do primeiro registrador ( flag de zero gerada automaticamnete )
        jnz LoopDelay ;Enquanto não for zero repete o processo
        loadn r0,#100
        sub r1,r1,r2 ;Quando r0 zerar tira um do r1 e restaura o r0 e volta pro loop
        jnz LoopDelay ;O loop so acaba qunado r0 e r1 forem 0
    pop r2
    pop r1
    pop r0
    rts
    ; O QUE FAZER:
    ; Copiar a logica de delay do codigo 'nave.asm'.
    ; E apenas um loop aninhado contando ate zero pra segurar o processador.


; ===================================================================
; TelaFinal: Mostra o resultado e trava o jogo
; Sugestao de responsavel: Covisi
; ===================================================================
TelaFinal:
    ; O QUE FAZER:
    ; 1. Ler 'GameOver'.
    ; 2. Se for 1, usar ImprimeStr pra mostrar 'MsgDerrota'.
    ; 3. Se for 2, usar ImprimeStr pra mostrar 'MsgVitoria'.
    ; (Opcional: Perguntar se quer jogar de novo).
    rts

; ===================================================================
; desenhacenario: imprime a interface estatica (rodado apenas uma vez)
; ===================================================================
DesenhaCenario:

    rts

; ===================================================================
; TelaInicial: Espera o jogador apertar uma tecla e gera a semente
; ===================================================================
TelaInicial:
    call printcenario1Screen    ; Carrega a tela inicial (cenario1)

    ; Imprime a mensagem na parte de baixo da tela
    loadn r0, #MsgTelaInicial
    loadn r1, #1120             ; Posicao na linha 28 (40 colunas * 28 = 1120)
    call ImprimeStr

    push r0     ; Guarda o input do teclado
    push r1     ; Guarda 255 (nenhuma tecla)
    push r2     ; O nosso contador super rapido (0 a 29)
    push r3     ; Limite do contador (30)

    loadn r1, #255
    loadn r2, #0
    loadn r3, #30

TelaInicial_Loop:
    inchar r0               ; Le o teclado sem travar
    cmp r0, r1              ; Compara com 255
    jne TelaInicial_Fim     ; Se for diferente (apertou algo!), sai do loop

    ; Se nao apertou nada, incrementa o nosso "relogio"
    inc r2
    cmp r2, r3              ; Chegou em 30?
    jne TelaInicial_Loop    ; Se nao chegou, volta a ler o teclado

    loadn r2, #0            ; Se chegou em 30, zera e volta a ler
    jmp TelaInicial_Loop

TelaInicial_Fim:
    ; O jogador apertou uma tecla!
    ; Salva o numero imprevisivel de r2 no IncRand
    store IncRand, r2

    ; Limpa a mensagem anterior desenhando o cenario novamente
    call printtabuleiro100Screen

    ; Imprime MsgComandos
    loadn r0, #MsgComandos
    loadn r1, #1000
    call ImprimeStr

    pop r3
    pop r2
    pop r1
    pop r0
    rts

; ===================================================================
ImprimeStr:
    push r0
    push r1
    push r2
    push r3

ImprimeStr_Loop:
    loadi r2, r0
    loadn r3, #'\0'
    cmp r2, r3
    jeq ImprimeStr_Fim

    ; Verifica se e nova linha (\n ou ASCII 10)
    loadn r3, #10
    cmp r2, r3
    jeq ImprimeStr_NewLine

    outchar r2, r1
    inc r1
    inc r0
    jmp ImprimeStr_Loop

ImprimeStr_NewLine:
    push r1
    pop r2                  ; r2 = r1
    
    loadn r3, #40
ImprimeStr_ModLoop:
    cmp r3, r2
    jgr ImprimeStr_ModEnd   ; Se 40 > r2 (ou seja, r2 < 40), sai do loop
    sub r2, r2, r3          ; r2 = r2 - 40
    jmp ImprimeStr_ModLoop
ImprimeStr_ModEnd:
    sub r1, r1, r2          ; r1 = r1 - (r1 % 40) -> inicio da linha atual
    add r1, r1, r3          ; r1 = r1 + 40 -> inicio da proxima linha
    
    inc r0                  ; Avanca o ponteiro da string
    jmp ImprimeStr_Loop

ImprimeStr_Fim:
    pop r3
    pop r2
    pop r1
    pop r0
    rts
