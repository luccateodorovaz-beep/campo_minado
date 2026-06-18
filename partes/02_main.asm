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

    call ImprimeTabuleiro
    call DesenhaCursor
    
LoopPrincipal_PulaRender:
    call Delay

    jmp LoopPrincipal

FimDeJogo:
    call TelaFinal
    halt
