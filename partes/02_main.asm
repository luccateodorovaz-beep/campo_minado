; ===================================================================
;                       PROGRAMA PRINCIPAL
; ===================================================================

main:
    call ApagaTela
    call IniciaVariaveis
    call DesenhaCenario
    call TelaInicial

    ; primeira renderizacao
    call ImprimeTabuleiro
    call DesenhaCursor
    call ImprimeContadores

LoopPrincipal:
    load r0, GameOver
    loadn r1, #0
    cmp r0, r1
    jne FimDeJogo

    call LeTeclado
    
    load r0, Letra
    loadn r1, #255
    cmp r0, r1
    jeq LoopPrincipal_PulaRender

    call MoveCursor
    call AcaoJogador

    ; --- Checagem de vitória ---
    load r0, GameOver
    loadn r1, #0
    cmp r0, r1
    jne LoopPrincipal       ; se já tiver GameOver, pula pro check do loop

    load r0, CasasSeguras
    loadn r1, #0
    cmp r0, r1
    jne PulaVitoria         ; se CasasSeguras != 0, continua

    loadn r0, #2
    store GameOver, r0      ; GameOver = 2 (vitória)

PulaVitoria:

    call ImprimeTabuleiro
    call DesenhaCursor
    call ImprimeContadores
    
LoopPrincipal_PulaRender:
    call AtualizaTempo
    call Delay

    jmp LoopPrincipal

FimDeJogo:
    call TelaFinal
    jmp main
