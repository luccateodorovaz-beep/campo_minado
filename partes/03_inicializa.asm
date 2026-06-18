; ===================================================================
; INÍCIO DAS SUBROTINAS
; ===================================================================

IniciaVariaveis:
    push r0
    push r1
    push r2

    loadn r0, #0

    store GameOver, r0
    store IncRand, r0

    loadn r3, #45
    store PosCursor, r3
    store PosAntCursor, r3

    loadn r3, #40
    store BombasRestantes, r3

    loadn r3, #60
    store CasasSeguras, r3      ; 100 casas - 40 bombas = 60 casas seguras

    loadn r1, #100
    loadn r2, #Tabuleiro
    loadn r0, #0

IniciaVariaveis_Loop:
    dec r1
    add r3, r2, r1
    storei r3, r0
    jnz IniciaVariaveis_Loop

    pop r3
    pop r2
    pop r1
    rts

ApagaTela:
    push r0
    push r1

    loadn r0, #1200
    loadn r1, #' '

ApagaTela_Loop:
    dec r0
    outchar r1, r0
    jnz ApagaTela_Loop
    pop r1
    pop r0
    rts
