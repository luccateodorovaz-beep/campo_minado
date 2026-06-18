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
PrimeiraJogada: var #1  ; Flag para indicar se eh o primeiro clique (1 = sim, 0 = nao)

; variaveis de input
Letra: var #1           ; tecla lida do teclado

; números "aleatórios" (baseado no nave.asm) para espalhar bombas
IncRand: var #1
Rand: var #100
static Rand + #0, #66
    static Rand + #1, #74
    static Rand + #2, #30
    static Rand + #3, #79
    static Rand + #4, #16
    static Rand + #5, #60
    static Rand + #6, #15
    static Rand + #7, #3
    static Rand + #8, #44
    static Rand + #9, #58
    static Rand + #10, #41
    static Rand + #11, #1
    static Rand + #12, #21
    static Rand + #13, #9
    static Rand + #14, #86
    static Rand + #15, #91
    static Rand + #16, #70
    static Rand + #17, #48
    static Rand + #18, #55
    static Rand + #19, #38
    static Rand + #20, #52
    static Rand + #21, #42
    static Rand + #22, #53
    static Rand + #23, #97
    static Rand + #24, #61
    static Rand + #25, #96
    static Rand + #26, #46
    static Rand + #27, #0
    static Rand + #28, #18
    static Rand + #29, #94
    static Rand + #30, #2
    static Rand + #31, #27
    static Rand + #32, #63
    static Rand + #33, #26
    static Rand + #34, #69
    static Rand + #35, #11
    static Rand + #36, #17
    static Rand + #37, #67
    static Rand + #38, #76
    static Rand + #39, #14
    static Rand + #40, #75
    static Rand + #41, #89
    static Rand + #42, #93
    static Rand + #43, #72
    static Rand + #44, #37
    static Rand + #45, #40
    static Rand + #46, #99
    static Rand + #47, #54
    static Rand + #48, #10
    static Rand + #49, #65
    static Rand + #50, #87
    static Rand + #51, #78
    static Rand + #52, #45
    static Rand + #53, #82
    static Rand + #54, #28
    static Rand + #55, #4
    static Rand + #56, #36
    static Rand + #57, #22
    static Rand + #58, #62
    static Rand + #59, #56
    static Rand + #60, #50
    static Rand + #61, #32
    static Rand + #62, #57
    static Rand + #63, #85
    static Rand + #64, #92
    static Rand + #65, #77
    static Rand + #66, #84
    static Rand + #67, #31
    static Rand + #68, #13
    static Rand + #69, #39
    static Rand + #70, #90
    static Rand + #71, #23
    static Rand + #72, #47
    static Rand + #73, #83
    static Rand + #74, #51
    static Rand + #75, #20
    static Rand + #76, #95
    static Rand + #77, #7
    static Rand + #78, #81
    static Rand + #79, #88
    static Rand + #80, #5
    static Rand + #81, #8
    static Rand + #82, #6
    static Rand + #83, #80
    static Rand + #84, #49
    static Rand + #85, #98
    static Rand + #86, #25
    static Rand + #87, #68
    static Rand + #88, #71
    static Rand + #89, #43
    static Rand + #90, #59
    static Rand + #91, #35
    static Rand + #92, #12
    static Rand + #93, #73
    static Rand + #94, #19
    static Rand + #95, #64
    static Rand + #96, #29
    static Rand + #97, #24
    static Rand + #98, #33
    static Rand + #99, #34

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


