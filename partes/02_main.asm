; ===================================================================
;                       PROGRAMA PRINCIPAL
; ===================================================================

main:
    call ApagaTela
    call IniciaVariaveis
    call DesenhaCenario
    call TelaInicial
    call GeraBombas
    call CalculaDicas

    ; primeira renderizacao
    call ImprimeTabuleiro
    call DesenhaCursor

LoopPrincipal:
    load r0, GameOver
    loadn r1, #0
    cmp r0, r1
    jne FimDeJogo

    call LeTeclado

    call MoveCursor
    call AcaoJogador

    call Delay

    jmp LoopPrincipal

FimDeJogo:
    call TelaFinal
    halt
