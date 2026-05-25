; ===================================================================
; Delay: Pausa a execucao por uma fracao de segundo
; Sugestao de responsavel: Lucca
; ===================================================================
Delay:
    ; O QUE FAZER:
    ; Copiar a logica de delay do codigo 'nave.asm'.
    ; E apenas um loop aninhado contando ate zero pra segurar o processador.
    rts

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

    pop r3
    pop r2
    pop r1
    pop r0
    rts
