; ======================================================================================
;                              C A M P O   M I N A D O
;                          por: Pedro Covisi e Lucca Vaz
; ======================================================================================

jmp main

; variaveis globais
; tabuleiro 10x10, vetor de 100 posicoes
Tabuleiro: var #100

; posicao do cursor
PosCursos: var #1
PosAntCursos: var #1

; controle de estado do jogo
GameOver: var #1        ; 0 = jogando, 1 = perdeu, 2 = venceu
BombasRestantes: var #1 ; Quantidade de bombas no mapa

; variaveis de input
Letra: var #1           ; tecla lida do teclado

; números "aleatórios" (baseado no nave.asm) para espalhar bombas
IncRand: var #1
Rand: var #30
    static Rand + #0, #15
    static Rand + #1, #32
    static Rand + #2, #77
    static Rand + #3, #12
    static Rand + #4, #61
    ; ... (podemos preencher com 30 valores de 0 a 99 depois) ...

; mensagens da interface
MsgTitulo: string "
 ======================================================================================
                              C A M P O   M I N A D O
                          por: Pedro Covisi e Lucca Vaz
 ======================================================================================
"
MsgComandos: string "Comandos:    Andar - WASD | Revelar - ESPAÇO | Colocar/tirar bandeira - F"
MsgDerrota: string "B O O M!! Você pisou em uma mina."
MsgVitoria: string "PARABENS! Você venceu!"


; ===================================================================
;                       PROGRAMA PRINCIPAL
; ===================================================================

main: 
    call ApagaTela
    call IniciarVariaveis
    call GeraBombas
    call CalculaDicas

    ; primeira renderizacao
    call ImprimeTabuleiro
    call DesenhaCursor

LoopPrincipal:
    load R0

