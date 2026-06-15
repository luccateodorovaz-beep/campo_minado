; ======================================================================================
;                              C A M P O   M I N A D O
;                   por: Pedro Covisi, Lucca Vaz e Antônio Carvalho
; ======================================================================================

jmp main

; variaveis globais
; tabuleiro 10x10, vetor de 100 posicoes
Tabuleiro: var #100

; posicao do cursor
PosCursor: var #1 ;Posição dentro do vetor tabuleiro que guarda se tem bomba ou não
PosAntCursor: var #1

; controle de estado do jogo
GameOver: var #1        ; 0 = jogando, 1 = perdeu, 2 = venceu
BombasRestantes: var #1 ; Quantidade de bombas no mapa (fixo: 15)
CasasSeguras: var #1    ; casas sem bomba ainda nao reveladas (inicia em 85 = 100 - 15)

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
    static Rand + #5, #8
    static Rand + #6, #94
    static Rand + #7, #23
    static Rand + #8, #56
    static Rand + #9, #89
    static Rand + #10, #3
    static Rand + #11, #42
    static Rand + #12, #70
    static Rand + #13, #19
    static Rand + #14, #81
    static Rand + #15, #48
    static Rand + #16, #99
    static Rand + #17, #27
    static Rand + #18, #53
    static Rand + #19, #6
    static Rand + #20, #38
    static Rand + #21, #64
    static Rand + #22, #91
    static Rand + #23, #11
    static Rand + #24, #75
    static Rand + #25, #84
    static Rand + #26, #2
    static Rand + #27, #35
    static Rand + #28, #59
    static Rand + #29, #22

; mensagens da interface
MsgTitulo: string "
 ======================================================================================
                              C A M P O   M I N A D O
                   por: Pedro Covisi, Lucca Vaz e Antônio Carvalho
 ======================================================================================
"
MsgComandos: string "Comandos\nAndar WASD\nRevelar ESPACO\nColocar ou tirar bandeira F"
MsgDerrota: string "B O O M!! Voce pisou em uma mina."
MsgVitoria: string "PARABENS! Voce venceu!"
MsgTelaInicial: string "Pressione qualquer tecla para comecar"


