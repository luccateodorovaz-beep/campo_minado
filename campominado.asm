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
MsgComandos: string "Comandos:\nAndar - WASD\nRevelar - ESPACO\nColocar/tirar bandeira - F"
MsgDerrota: string "B O O M!! Voce pisou em uma mina."
MsgVitoria: string "PARABENS! Voce venceu!"
MsgTelaInicial: string "Pressione qualquer tecla para comecar"


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

    loadn r3, #15
    store BombasRestantes, r3

    loadn r3, #85
    store CasasSeguras, r3      ; 100 casas - 15 bombas = 85 casas seguras

    loadn r1, #100
    loadn r2, #Tabuleiro

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
;Bloco de sorteiro
; ===================================================================
; GeraBombas: Sorteia as posicoes e espalha as bombas no vetor
; Sugestao de responsavel: Covisi
; ===================================================================
GeraBombas:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    load r0, BombasRestantes
    load r1, IncRand    ; le em qual posicao da tabela estamos
    loadn r2, #Rand    ; ponteiro para a tabela de numeros pseudoaleatorios
    loadn r3, #Tabuleiro      ; ponteiro para o grid do jogo
    loadn r4, #1    ; mascara or para setar a bomba (bit 0)

GeraBombasLoop:
    ; acessa a posiçao do vetor rand
    add r5, r2, r1      ; soma o endereço do vetor (r2), com o nosso indice (r1) e guarda em r5
    loadi r5, r5    ; carrega o valor que esta no endereço apontado por r5 no proprio r5

    ; vai ate a posicao sorteada e liga o bit da bomba
    add r5, r3, r5
    loadi r7, r5     ; r7 = le o que tem la atualmente
    or r7, r7, r4    ; faz or com 1. se estava 0, vira 1.
    storei r5, r7

    ; atualiza o indice de rand para nao repetir numero
    inc r1
    loadn r6, #30
    cmp r1, r6      ; compara se chegou no fim da tabela (30)
    jne GeraBombas_PulaReset
    loadn r1, #0

GeraBombas_PulaReset:
    dec r0      ; decrementa de bombas restantes
    jnz GeraBombasLoop

    store IncRand, r1

    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

;Bloco de Bombas Vizinhas
; ===================================================================
; CalculaDicas: Conta as bombas vizinhas de cada celula vazia
; Sugestao de responsavel: Lucca
; ===================================================================
CalculaDicas: 
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    loadn r0, #Tabuleiro ; Base
    loadn r1, #0         ; Índice principal (0 a 99)
    loadn r2, #0         ; Coluna Otimizada (0 a 9). Começa na coluna 0.

LoopCalculaDicas:
    ; 1. Checagem de Fim de Loop ( chega para ver se se o r1 chegou em 100 sse sim acabou o loop / o máximo que ele deveria chegar é 99)
    loadn r4,#100
    cmp r1, r4
    jeq FimCalculaDicas

    ; 2. LÊ A CASA ATUAL
    add r3, r0, r1       ; r3 = endereço atual (Tabuleiro + indice)
    loadi r5, r3         ; r5 = o que tem na casa

    ; 3. CHECA SE TEM BOMBA
    loadn r4, #1         ; Usamos o r4 para fazer o AND 
    and r6, r5, r4       ; Filtra o bit 0 ( se r6 =1 tem boma se for 0 não te )
    cmp r6, r4           ; Compara com 1
    jeq ProximaCasa      ; Se tem bomba pula para a próxima casa

    ;4. CASO NÃO HAJA BOMBA VERIFICA VIZINHOS ( já que nem todas as posições tem todos os vizinhos faremos por partes)
    loadn r7,#0 ;Conta quantas bombas tem em volta
    TestaCima:;Testa valores em cima da posição atual

        push r0 ;Guarda o endereço de tabuleiro para depois 
        push r5; Guarda o contador principal 

        loadn r0,#10;Vai estar em cima se r1 menor que 10 então:
        cmp r1,r0 
        jle FimTesteCima ; Se for menor que 10 pula para próxima verificação pois não tem ninguém em cima

        ;Caso continue aqui verificamos agora os que estão em cima
        loadn r5,#1 ;Usado para fazer o AND

        VerificaemCima:
        sub r0,r3,r0 ; Subtrai 10 de r3 para ver quem está em cima e guarda em r0
        loadi r0,r0; Dou um laodi do que está no endereço r0 dentro do prórpio r0 
        and r0,r0,r5; Faço o and e guardo em r0 ( se der 1 tem bomba )
        add r7,r0,r7 ; Somo o que deu, se deu bomba vai adicionar 1, se não, nada muda

        ;Verifica Diagonal Esquerda Alto condição 
        loadn r0,#0 ;Usado para ver se coluna da esqueda é a coluna zero ( do canto ), não tenho diagonal
        cmp r2,r0
        jeq VerificaDiagonalDireitaAlto ; Se for igual quer dizer que está no canto esquerdo, logo pulamos para a verficação do canto direito

        VerificaDiagonalEsquerdaAlto:
        loadn r0,#11 ;O que está a esquerda de quem ta em cima
        sub r0,r3,r0 ;r0 agora é o enderço da diagonal esquerda
        loadi r0,r0 ;O valor do endereço da diagonal esquerda
        and r0,r0,r5 ;Fiz and 
        add r7,r0,r7;Mesma Lógica de cima

        ;Verifica Diagonal Direita Alto condição
        loadn r0,#9 ; Verifica se coluna da direita é a coluna 9 ( utlima coluna )
        cmp r2,r0 ; Compara
        jeq FimTesteCima ; Se for igual, já que o teste da diagonal esquerda ja foi feito, podemos encerrar os testes em cima

        VerificaDiagonalDireitaAlto:
        loadn r0,#9 ; Endereço da esqueda de quem ta em cima
        sub r0,r3,r0 ; Subtrai 9 do endereço atual para descobrir endereço da diagonal direita
        loadi r0,r0 ;Ve quem está dentro desse endereõ
        and r0,r5,r0 ;Faz o and com r5 ( que foi atribuido la em cima como 1)
        add r7,r0,r7; Independetne do resultado soma com r7 ( se der 0 não vai mudar em nada )
        jmp FimTesteCima
        

    FimTesteCima:
        pop r5
        pop r0
        jmp TesteBaixo

    TesteBaixo:;Testamos valores em baixo da posição atual 
    push r0
    push r5
    
    loadn r0, #89 ; Se for maior que 89 o vetor esta na linha de baixo 
    cmp r1,r0
    jgr FimTesteBaixo ; Se for maior que 89 está na linha de baixo, logo não ninguém para verificar em baixo 

    ;Se ficou temos que comparar em baixo e suas diagonais 
    
    ;Inicializando valor para fazer o AND 
    loadn r5,#1

        VerificaBaixo: ; Verificamos a posição exatamente em baixo
        loadn r0,#10 ; Carregamos o 10 par poder nos deslocar por colunas
        add r0,r3,r0 ; Soma  10 de r3 para ver quem está em baixo e guarda em r0
        loadi r0,r0; Dou um laodi do que está no endereço r0 dentro do prórpio r0 
        and r0,r0,r5; Faço o and e guardo em r0 ( se der 1 tem bomba )
        add r7,r0,r7 ; Somo o que deu, se deu bomba vai adicionar 1, se não, nada muda

    ;Verifica Diagonal Esquerda Baixo condição
        loadn r0,#0 ;Usado para ver se coluna da esqueda é a coluna zero ( do canto ), não tenho diagonal
        cmp r2,r0
        jeq VerificaDiagonalDireitaBaixo ; Se for igual quer dizer que está no canto esquerdo, logo pulamos para a verficação do canto direito

        VerificaDiagonalEsquerdaBaixo:
        loadn r0,#9 ;O que está a esquerda de quem ta em baixo (não é 11 como em cima para ver esqueda )
        add r0,r3,r0 ;r0 agora é o enderço da diagonal de baixo
        loadi r0,r0 ;O valor do endereço da diagonal esquerda de baixo
        and r0,r0,r5 ;Fazemos o and
        add r7,r0,r7;Mesma Lógica do verifica em baixo 

    ;Verifica Diagonal Direita Baixo condição
        loadn r0,#9 ; Verifica se coluna da direita é a coluna 9 ( utlima coluna )
        cmp r2,r0 ; Compara
        jeq FimTesteBaixo ; Se for igual, já que o teste da diagonal esquerda ja foi feito, podemos encerrar os testes em cima

        VerificaDiagonalDireitaBaixo:
        loadn r0,#11 ; Endereço da esqueda de quem ta em cima
        add r0,r3,r0 ; Subtrai 9 do endereço atual para descobrir endereço da diagonal direita
        loadi r0,r0 ;Ve quem está dentro desse endereõ
        and r0,r5,r0 ;Faz o and com r5 ( que foi atribuido la em cima como 1)
        add r7,r0,r7; Independetne do resultado soma com r7 ( se der 0 não vai mudar em nada )
    

    FimTesteBaixo:
    pop r5
    pop r0
    jmp TesteLado


    TesteLado:;Testamos os valores da direita e da esquerda ( diagonal ja foi testada em teste cima e baixo )
;Guardando valores importantes
        push r0
        push r5 
;Seta valor para fazer AND
        loadn r5,#1

; Verifica Esquerda Condição
         loadn r0,#0
         cmp r0,r2
        jeq TesteLadoDireito

        TesteLadoEsquerdo:
        loadn r0,#1 
        sub r0,r3,r0 ;Subtrai o enderço atual ( r3 = r0incial + r1 ( posição incial do vetor + número de andadas ))
        loadi r0,r0 ;Pega o valor desse endereço 
        and r0,r5,r0; Faz o and 
        add r7,r0,r7 ; Guarda a soma com r7 ( se tiver bomba vai somar um se nao, não soma nada )

;Verifica Direita Condição
        loadn r0,#9
        cmp r0,r2 ; Ve se não está na útlima fileira 
         jeq FimTesteLado

        TesteLadoDireito:
        loadn r0,#1 
        add r0,r3,r0 ;Subtrai o enderço atual ( r3 = r0incial + r1 ( posição incial do vetor + número de andadas ))
        loadi r0,r0 ;Pega o valor desse endereço 
        and r0,r5,r0; Faz o and 
        add r7,r0,r7 ; Guarda a soma com r7 ( se tiver bomba vai somar um se nao, não soma nada )

FimTesteLado:
pop r5
pop r0
jmp SomaBits

SomaBits: 
    ; Aqui temos que colocar o valor de r7 nos bits 3 a 6 
    SHIFTL0 r7, #3    ; Shifta 3 casas (bit 0 vai para o bit 3)

    or r5, r5, r7   ; Também poderia ser: OR r5, r5, r7

    ; Guarda o valor final de volta no endereço apontado por r3
    storei r3, r5    

    jmp ProximaCasa


ProximaCasa:
    inc r1               ; Anda um passo no tabuleiro geral
    inc r2               ; Anda um passo na nossa coluna
    
    ; Checa se a coluna estourou o limite da tela (chegou no 10)
    loadn r4, #10
    cmp r2, r4
    jne PulaResetaColuna ; Se não deu 10, continua normal
    loadn r2, #0         ; Se deu 10, quebra a linha (volta pra coluna 0!)

PulaResetaColuna:
    jmp LoopCalculaDicas

FimCalculaDicas:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
    ; O QUE FAZER:
    ; 1. Fazer um loop de 0 a 99 (passando por todo o Tabuleiro).
    ; 2. Se a posicao atual tiver bomba, pula pra proxima.
    ; 3. Se nao tiver, checa os 8 vizinhos (cima, baixo, lados e diagonais).
    ; 4. Conta quantas bombas tem ao redor e guarda esse numero nos Bits 3 a 6.
    ; DICA: Cuidado com as bordas (ex: a posicao 9 nao tem vizinho na direita).

;Bloco de desenho

; ===================================================================
; ImprimeTabuleiro
; ===================================================================
ImprimeTabuleiro:
    push r0     ; logic index (0 to 99)
    push r1     ; Y counter (0 to 9)
    push r2     ; X counter (0 to 9)
    push r3     ; Screen offset
    push r4     ; value from memory
    push r5     ; temp / char to print
    push r6     ; screen offset helper
    
    loadn r0, #0
    loadn r3, #90       ; Start pos (x=10, y=2) -> offset = 2*40 + 10 = 90
    loadn r1, #0
ImprimeTabuleiro_LoopY:
    loadn r5, #10
    cmp r1, r5
    jeq ImprimeTabuleiro_Fim
    
    loadn r2, #0
ImprimeTabuleiro_LoopX:
    loadn r5, #10
    cmp r2, r5
    jeq ImprimeTabuleiro_NextY
    
    ; --- Draw logic ---
    loadn r5, #Tabuleiro
    add r5, r5, r0
    loadi r4, r5        ; r4 recebe o valor que esta no Tabuleiro
    
    loadn r5, #4        ; mask bit 2 (bandeira)
    and r4, r4, r5      ; isola o bit 2 em r4
    
    loadn r5, #0
    cmp r4, r5
    jeq ImprimeTabuleiro_Vazio

ImprimeTabuleiro_Flag:
    ; top-left: flag4 (char 12)
    loadn r5, #12
    outchar r5, r3
    
    ; top-right: flag3 (char 11)
    loadn r5, #11
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    ; bottom-left: flag1 (char 9)
    loadn r5, #9
    push r3
    pop r6
    loadn r4, #40
    add r6, r6, r4
    outchar r5, r6
    
    ; bottom-right: flag2 (char 10)
    loadn r5, #10
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Vazio:
    ; top-left: grade4 (char 7)
    loadn r5, #7
    outchar r5, r3
    
    ; top-right: grade3 (char 6)
    loadn r5, #6
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    ; bottom-left: grade1 (char 31)
    loadn r5, #31
    push r3
    pop r6
    loadn r4, #40
    add r6, r6, r4
    outchar r5, r6
    
    ; bottom-right: grade2 (char 5)
    loadn r5, #5
    inc r6
    outchar r5, r6

ImprimeTabuleiro_Prox:
    inc r0
    loadn r5, #2
    add r3, r3, r5      ; proxima coluna do tabuleiro pula 2 posicoes na tela
    inc r2
    jmp ImprimeTabuleiro_LoopX

ImprimeTabuleiro_NextY:
    inc r1
    loadn r5, #60
    add r3, r3, r5      ; pula 2 linhas para baixo e volta ao inicio do X (diff = +60)
    jmp ImprimeTabuleiro_LoopY

ImprimeTabuleiro_Fim:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
; ===================================================================
; DesenhaCursor: Destaca a posicao atual do jogador na tela
; Sugestao de responsavel: Lucca
;
; ===================================================================
DesenhaCursor:
    push r0
    push r1
    push r2
    push r6
    
    load r0, PosCursor
    loadn r6, #90       ; Start pos na tela (x=10, y=2) = offset 90
    loadn r1, #9
DesenhaCursor_DivLoop:
    cmp r1, r0
    jgr DesenhaCursor_DivEnd    ; se r1 > r0 (ou seja r0 <= 9), ja achou a linha
    jeq DesenhaCursor_DivEnd    ; se r1 == r0, ja achou a linha
    loadn r2, #10
    sub r0, r0, r2      ; Subtrai 10 da posicao logica (equivale a subir 1 linha no tabuleiro)
    loadn r2, #80
    add r6, r6, r2      ; Soma 80 no offset da tela (pula 2 linhas de 40)
    jmp DesenhaCursor_DivLoop
DesenhaCursor_DivEnd:
    add r0, r0, r0      ; r0 = r0 * 2 (cada X lógico ocupa 2 posições físicas na tela)
    add r6, r6, r0      ; r6 agora tem o offset exato na tela
    
    ; top-left: cursor4 (char 16)
    loadn r1, #16
    outchar r1, r6
    
    ; top-right: cursor3 (char 15)
    loadn r1, #15
    push r6
    pop r2
    inc r2
    outchar r1, r2
    
    ; bottom-left: cursor1 (char 13)
    loadn r1, #13
    push r6
    pop r2
    loadn r0, #40
    add r2, r2, r0
    outchar r1, r2
    
    ; bottom-right: cursor2 (char 14)
    loadn r1, #14
    inc r2
    outchar r1, r2

    pop r6
    pop r2
    pop r1
    pop r0
    rts

; ===================================================================
; MoveCursor: Atualiza a posicao do cursor usando WASD
; Sugestao de responsavel: Lucca
; Feito por: Antonio
; ===================================================================
; Layout do tabuleiro (posicoes 0 a 99):
;   linha 0 → posicoes  0 a  9
;   linha 1 → posicoes 10 a 19
;   ...
;   linha 9 → posicoes 90 a 99
;
; Registradores usados:
;   r0 = tecla lida (Letra)
;   r1 = PosCursor atual
;   r2 = constante de comparacao / nova posicao
;   r3 = auxiliar para calculo de coluna (MOD 10)
; ===================================================================
MoveCursor:
    push r0
    push r1
    push r2
    push r3

    load r0, Letra      ; le a tecla pressionada pelo jogador
    load r1, PosCursor  ; le a posicao atual do cursor no tabuleiro

    ; ------------------------------------------------------------------
    ; W — mover para CIMA (subtrai 10 da posicao)
    ; ------------------------------------------------------------------
    loadn r2, #'w'
    cmp r0, r2
    jne MoveCursor_S            ; nao e 'w', testa proximo

    loadn r2, #9
    cmp r1, r2
    jle MoveCursor_Fim          ; pos <= 9 → ja esta na primeira linha, nao move

    store PosAntCursor, r1      ; salva posicao anterior antes de mover
    loadn r2, #10
    sub r1, r1, r2              ; sobe uma linha: pos = pos - 10
    store PosCursor, r1
    jmp MoveCursor_Fim

    ; ------------------------------------------------------------------
    ; S — mover para BAIXO (soma 10 da posicao)
    ; ------------------------------------------------------------------
MoveCursor_S:
    loadn r2, #'s'
    cmp r0, r2
    jne MoveCursor_A            ; nao e 's', testa proximo

    loadn r2, #89
    cmp r1, r2
    jgr MoveCursor_Fim          ; pos > 89 -> ja esta na ultima linha, nao move

    loadn r2, #10
    add r2, r1, r2              ; r2 = nova posicao (pos + 10)
    store PosAntCursor, r1
    store PosCursor, r2         ; desce uma linha
    jmp MoveCursor_Fim

    ; ------------------------------------------------------------------
    ; A — mover para ESQUERDA (subtrai 1)
    ; Permite voltar para a linha de cima, travando apenas na posicao 0
    ; ------------------------------------------------------------------
MoveCursor_A:
    loadn r2, #'a'
    cmp r0, r2
    jne MoveCursor_D            ; nao e 'a', testa proximo

    loadn r2, #0
    cmp r1, r2
    jeq MoveCursor_Fim          ; pos == 0 -> inicio do tabuleiro, nao move

    store PosAntCursor, r1
    dec r1                      ; anda um passo a esquerda: pos = pos - 1
    store PosCursor, r1
    jmp MoveCursor_Fim

    ; ------------------------------------------------------------------
    ; D — mover para DIREITA (soma 1)
    ; Permite descer para a linha de baixo, travando apenas na posicao 99
    ; ------------------------------------------------------------------
MoveCursor_D:
    loadn r2, #'d'
    cmp r0, r2
    jne MoveCursor_Fim          ; nao e 'd', nenhuma tecla valida

    loadn r2, #99
    cmp r1, r2
    jeq MoveCursor_Fim          ; pos == 99 -> fim do tabuleiro, nao move

    store PosAntCursor, r1
    inc r1                      ; anda um passo a direita: pos = pos + 1
    store PosCursor, r1

MoveCursor_Fim:
    pop r3
    pop r2
    pop r1
    pop r0
    rts
; ===================================================================
; LeTeclado: Captura a tecla pressionada sem travar o jogo
; Sugestao de responsavel: Covisi
; Feito por: Antonio
; ===================================================================
LeTeclado:
    push r0

    inchar r0        ; le o teclado sem travar (255 = nenhuma tecla)
    store Letra, r0  ; grava sempre: seja 255 ou uma tecla real

    pop r0
    rts

; ===================================================================
; AcaoJogador: Processa a abertura de casas ou colocacao de bandeiras
; Sugestao de responsavel: Covisi
; ===================================================================
AcaoJogador:
push r0
push r1
push r2
push r3
push r4
push r5
push r6
push r7
loadn r0,#'f'         ;Tecla f em r0 ( adiciona flag )
loadn r1,#' '         ; Tecla espaço em r1 ( revela posição atual )
LoopAcaoJogador:
    ;Ver qual tecla é
    load r3,Letra     ;Le tecla atual
    cmp r0,r3         ;Ve se input é f e se for faz açaõ necessária
    jeq AcaoF
    cmp r3,r1         ;Ve se input é espaço e se for faz ação necessária
    jeq AcaoEspaco
    jne FinalAcaoJogador ; Se não for nem f nem espaço volta para o loop principal

    ;Primeiro função do F
    AcaoF:
        load r0, PosCursor          ;Ve posição do cursor em relação ao inicio do vetor
        loadn r1,#Tabuleiro
        add r1,r1,r0                ;Ve posição atual do vetor que jogador se encontra 
        loadi r4,r1                 ;Carrega o valor do endereço de r1 no r4
        loadn r2,#4                 ;So o segundo bit ligado // 00000100
        xor r3,r2,r4                ;Agora basta fazer o xor com 4 porque se bit 2 for 0 vira 1 e se for 1 vira 0
        storei r1,r3                ;Carrega o valor atualizado no endereço de r1
        jmp FinalAcaoJogador

    AcaoEspaco:
        load r0, PosCursor          ;Ve posição do cursor em relação ao inicio do vetor
        loadn r1,#Tabuleiro
        add r1,r1,r0                ;Ve posição atual do vetor que jogador se encontra 
        loadi r4,r1                 ;Carrega valor do endereço r1 em r4
        ChecaBit0:                  ;Vai dizer se tem bomba ou não 
            loadn r2,#1             ;Para comprar o ultimo bit apenas
            and r3,r4,r2            ;Faz o and entre r4 (valor) e r2 (máscara) e guarda em r3
            jnz SetGameOverLose     ;Se não for zero tem bomba logo acabou o jogo
            
            ; Se não for bomba, o jogo continua. Pula direto para revelar a casa atual
            jmp LigaBit1
    
        LigaBit1:                   ;Ligar o bit 1 quer dizer revelar a casa escondida
            ;Antes inicializamos tudo que vamos usar em registradores diferentes
            load r0, PosCursor      ;r0 é posição do cursor ( 0 a 99 )
            loadn r1, #Tabuleiro    ;r1 é o endereço do tabuleiro ( inicio do vetor )
            add r2, r1, r0          ;r2 é o endereço da posição atual 
            loadi r4, r2            ;r4 é o valor da casa atual 
            ;Agora ligamos o bit da casa atual 
            loadn r5,#2             ;r5 é o valor para ligar o bit1 ( 2 )
            or r6,r4,r5             ;r6 é o valor atualizado 
            storei r2,r6            ;Guarda valor atualizado (r6) no endereço apontado por r2
            ;E agora Decrementamos casas seguras 
            load r7, CasasSeguras
            dec r7
            store CasasSeguras, r7  ;Decrementa casas seguras 

         PrepBaixo:
            add r2,r0,r1            ; Restaura r2 para a casa original do clique
            LigaBit1AdjacenteBaixo:
                sub r5,r2,r1        ; r5 = índice atual 
                
                ; Teste de Linha: Não pode descer se já estiver na última linha
                loadn r7,#89
                cmp r5,r7           
                jgr PrepCima        ; Se índice > 89, para o raio
                
                ; Avança o endereço
                loadn r7,#10
                add r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           ; r4 = 1 significa que bateu numa bomba/casa revelada
                jeq PrepCima        
                jmp LigaBit1AdjacenteBaixo 


        PrepCima:
            add r2,r0,r1            
            LigaBit1AdjacenteCima:
                sub r5,r2,r1        
                
                ; Teste de Linha: Não pode subir se já estiver na primeira linha
                loadn r7,#9
                cmp r5,r7           
                jle PrepEsquerda    ; Se índice <= 9, para o raio
                
                ; Avança o endereço
                loadn r7,#10
                sub r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepEsquerda    
                jmp LigaBit1AdjacenteCima 


        PrepEsquerda:
            add r2,r0,r1            
            LigaBit1AdjacenteEsquerda:
                sub r5,r2,r1        
                
                ; --- Teste de Coluna: Esquerda (Impede Pac-Man) ---
                loadn r6, #0
                add r3, r5, r6      ; Copia r5 para r3 de forma segura (sem usar 'mov')
                LoopModEsq:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10Esq
                    jmp FimModEsq
                Sub10Esq:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModEsq
                FimModEsq:
                loadn r6, #0        
                cmp r3, r6
                jeq PrepDireita     ; Se resto == 0, está na borda esquerda. Para o raio.
                ; --------------------------------------------------
                
                ; Avança o endereço
                loadn r7,#1
                sub r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepDireita    
                jmp LigaBit1AdjacenteEsquerda 


        PrepDireita:
            add r2,r0,r1            
            LigaBit1AdjacenteDireita:
                sub r5,r2,r1        
                
                ; --- Teste de Coluna: Direita (Impede Pac-Man) ---
                loadn r6, #0
                add r3, r5, r6      
                LoopModDir:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10Dir
                    jmp FimModDir
                Sub10Dir:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModDir
                FimModDir:
                loadn r6, #9        
                cmp r3, r6
                jeq PrepDiagCimaEsq ; Se resto == 9, está na borda direita. Para o raio.
                ; --------------------------------------------------
                
                ; Avança o endereço
                loadn r7,#1
                add r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepDiagCimaEsq    
                jmp LigaBit1AdjacenteDireita 


        PrepDiagCimaEsq:
            add r2,r0,r1            
            LigaBit1AdjacenteDiagonalCimaEsquerda:
                sub r5,r2,r1        
                
                ; 1. Teste de Linha: Não pode subir se estiver na primeira linha
                loadn r7,#9
                cmp r5,r7           
                jle PrepDiagCimaDir 
                
                ; 2. Teste de Coluna: Não pode ir pra esquerda se estiver na coluna 0
                loadn r6, #0
                add r3, r5, r6      
                LoopModCimaEsq:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10CimaEsq
                    jmp FimModCimaEsq
                Sub10CimaEsq:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModCimaEsq
                FimModCimaEsq:
                loadn r6, #0
                cmp r3, r6
                jeq PrepDiagCimaDir 
                
                ; Avança o endereço
                loadn r7,#11
                sub r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepDiagCimaDir    
                jmp LigaBit1AdjacenteDiagonalCimaEsquerda 


        PrepDiagCimaDir:
            add r2,r0,r1            
            LigaBit1AdjacenteDiagonalCimaDireita:
                sub r5,r2,r1        
                
                ; 1. Teste de Linha: Não pode subir
                loadn r7,#9
                cmp r5,r7           
                jle PrepDiagBaixoEsq 
                
                ; 2. Teste de Coluna: Não pode ir pra direita se estiver na coluna 9
                loadn r6, #0
                add r3, r5, r6      
                LoopModCimaDir:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10CimaDir
                    jmp FimModCimaDir
                Sub10CimaDir:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModCimaDir
                FimModCimaDir:
                loadn r6, #9
                cmp r3, r6
                jeq PrepDiagBaixoEsq 
                
                ; Avança o endereço
                loadn r7,#9
                sub r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepDiagBaixoEsq    
                jmp LigaBit1AdjacenteDiagonalCimaDireita 


        PrepDiagBaixoEsq:
            add r2,r0,r1            
            LigaBit1AdjacenteDiagonalBaixoEsquerda:
                sub r5,r2,r1        
                
                ; 1. Teste de Linha: Não pode descer
                loadn r7,#89
                cmp r5,r7           
                jgr PrepDiagBaixoDir 
                
                ; 2. Teste de Coluna: Não pode ir pra esquerda
                loadn r6, #0
                add r3, r5, r6      
                LoopModBaixoEsq:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10BaixoEsq
                    jmp FimModBaixoEsq
                Sub10BaixoEsq:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModBaixoEsq
                FimModBaixoEsq:
                loadn r6, #0
                cmp r3, r6
                jeq PrepDiagBaixoDir 
                
                ; Avança o endereço
                loadn r7,#9
                add r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5           
                jeq PrepDiagBaixoDir    
                jmp LigaBit1AdjacenteDiagonalBaixoEsquerda 


        PrepDiagBaixoDir:
            add r2,r0,r1            
            LigaBit1AdjacenteDiagonalBaixoDireita:
                sub r5,r2,r1        
                
                ; 1. Teste de Linha: Não pode descer
                loadn r7,#89
                cmp r5,r7           
                jgr FinalAcaoJogador   
                
                ; 2. Teste de Coluna: Não pode ir pra direita
                loadn r6, #0
                add r3, r5, r6      
                LoopModBaixoDir:
                    loadn r6, #9
                    cmp r3, r6
                    jgr Sub10BaixoDir
                    jmp FimModBaixoDir
                Sub10BaixoDir:
                    loadn r6, #10
                    sub r3, r3, r6
                    jmp LoopModBaixoDir
                FimModBaixoDir:
                loadn r6, #9
                cmp r3, r6
                jeq FinalAcaoJogador
                
                ; Avança o endereço
                loadn r7,#11
                add r2,r2,r7        
                
                call ProcessaCasaVizinha 
                
                loadn r5,#1
                cmp r4,r5 ;r4 ( que foi modificado pela função Processa Casa Vizinha )será igual a 1 se o caminho foi obstruido ( tem bomba)       
                jeq FinalAcaoJogador;Se for igual é porque a última rotina ( Diag Baixa Direita ) acabou, logo a ação espaço acabou    
                jmp LigaBit1AdjacenteDiagonalBaixoDireita

    ; ===================================================================
; ProcessaCasaVizinha: Checa bomba/revelado, liga bit e decrementa
; Entra: r2 = endereço da casa que o raio acabou de alcançar
; Sai:   r4 = 1 se o raio deve parar, 0 se pode continuar correndo
; ===================================================================
ProcessaCasaVizinha:
    loadi r4, r2                ; Lê o valor da casa atual na RAM
    
    ; 1. Testa bomba (bit 0)
    loadn r5, #1         
    and r5, r5, r4        
    jnz ParaORaio               ; Se tem bomba, avisa para parar o raio
    
    ; 2. Testa se já foi revelada (bit 1)
    loadn r5, #2         
    and r5, r5, r4        
    jnz ParaORaio               ; Se já está aberta, avisa para parar o raio
    
    ; 3. Casa segura e fechada! Liga o Bit 1
    loadn r5, #2         
    or r4, r5, r4         
    storei r2, r4               ; Grava o bit ligado na RAM
    
    ; 4. Decrementa Casas Seguras
    load r7, CasasSeguras
    dec r7
    store CasasSeguras, r7 
    
    loadn r4, #0                ; Retorna r4 = 0 (Caminho livre, continue correndo)
    rts                         

ParaORaio:
    loadn r4, #1                ; Retorna r4 = 1 (Obstáculo encontrado, pare o raio)
    rts

    ;So vai chegar ate aqui se tiver achado bomba ao liberar
    SetGameOverLose:
        loadn r2, #1                    ; Seta flag de derrota (1)
        store GameOver, r2
        jmp FinalAcaoJogador

    SetGameOverWin:
        loadn r2, #2                    ; Seta flag de vitória (2)
        store GameOver, r2
        jmp FinalAcaoJogador

FinalAcaoJogador:
pop r7
pop r6
pop r5
pop r4
pop r3
pop r2
pop r1
pop r0
rts; ===================================================================
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
; ===========================================================
; CENARIO 1 (tela inicial)
; ===========================================================
cenario1 : var #1200
  ;Linha 0
  static cenario1 + #0, #1536
  static cenario1 + #1, #1536
  static cenario1 + #2, #1536
  static cenario1 + #3, #1536
  static cenario1 + #4, #1536
  static cenario1 + #5, #1536
  static cenario1 + #6, #1536
  static cenario1 + #7, #1536
  static cenario1 + #8, #1536
  static cenario1 + #9, #1536
  static cenario1 + #10, #1536
  static cenario1 + #11, #1536
  static cenario1 + #12, #1536
  static cenario1 + #13, #1536
  static cenario1 + #14, #1536
  static cenario1 + #15, #1536
  static cenario1 + #16, #1536
  static cenario1 + #17, #1536
  static cenario1 + #18, #1536
  static cenario1 + #19, #1536
  static cenario1 + #20, #1536
  static cenario1 + #21, #1536
  static cenario1 + #22, #1536
  static cenario1 + #23, #1536
  static cenario1 + #24, #1536
  static cenario1 + #25, #1536
  static cenario1 + #26, #1536
  static cenario1 + #27, #1536
  static cenario1 + #28, #0
  static cenario1 + #29, #0
  static cenario1 + #30, #0
  static cenario1 + #31, #1536
  static cenario1 + #32, #1536
  static cenario1 + #33, #1536
  static cenario1 + #34, #1536
  static cenario1 + #35, #1536
  static cenario1 + #36, #1536
  static cenario1 + #37, #1536
  static cenario1 + #38, #1536
  static cenario1 + #39, #1536

  ;Linha 1
  static cenario1 + #40, #1536
  static cenario1 + #41, #1536
  static cenario1 + #42, #1536
  static cenario1 + #43, #1536
  static cenario1 + #44, #0
  static cenario1 + #45, #0
  static cenario1 + #46, #0
  static cenario1 + #47, #1536
  static cenario1 + #48, #1536
  static cenario1 + #49, #1536
  static cenario1 + #50, #1536
  static cenario1 + #51, #1536
  static cenario1 + #52, #1536
  static cenario1 + #53, #1536
  static cenario1 + #54, #1536
  static cenario1 + #55, #1536
  static cenario1 + #56, #1536
  static cenario1 + #57, #1536
  static cenario1 + #58, #1536
  static cenario1 + #59, #1536
  static cenario1 + #60, #1536
  static cenario1 + #61, #1536
  static cenario1 + #62, #1536
  static cenario1 + #63, #1536
  static cenario1 + #64, #1536
  static cenario1 + #65, #1536
  static cenario1 + #66, #1536
  static cenario1 + #67, #0
  static cenario1 + #68, #0
  static cenario1 + #69, #0
  static cenario1 + #70, #0
  static cenario1 + #71, #0
  static cenario1 + #72, #1536
  static cenario1 + #73, #1536
  static cenario1 + #74, #1536
  static cenario1 + #75, #1536
  static cenario1 + #76, #1536
  static cenario1 + #77, #1536
  static cenario1 + #78, #1536
  static cenario1 + #79, #1536

  ;Linha 2
  static cenario1 + #80, #1536
  static cenario1 + #81, #1536
  static cenario1 + #82, #0
  static cenario1 + #83, #0
  static cenario1 + #84, #0
  static cenario1 + #85, #0
  static cenario1 + #86, #0
  static cenario1 + #87, #0
  static cenario1 + #88, #0
  static cenario1 + #89, #0
  static cenario1 + #90, #1536
  static cenario1 + #91, #1536
  static cenario1 + #92, #1536
  static cenario1 + #93, #1536
  static cenario1 + #94, #1536
  static cenario1 + #95, #1536
  static cenario1 + #96, #1536
  static cenario1 + #97, #1536
  static cenario1 + #98, #1536
  static cenario1 + #99, #1536
  static cenario1 + #100, #1536
  static cenario1 + #101, #1536
  static cenario1 + #102, #1536
  static cenario1 + #103, #1536
  static cenario1 + #104, #1536
  static cenario1 + #105, #1536
  static cenario1 + #106, #0
  static cenario1 + #107, #0
  static cenario1 + #108, #0
  static cenario1 + #109, #0
  static cenario1 + #110, #0
  static cenario1 + #111, #0
  static cenario1 + #112, #0
  static cenario1 + #113, #0
  static cenario1 + #114, #1536
  static cenario1 + #115, #1536
  static cenario1 + #116, #1536
  static cenario1 + #117, #1536
  static cenario1 + #118, #1536
  static cenario1 + #119, #1536

  ;Linha 3
  static cenario1 + #120, #1536
  static cenario1 + #121, #0
  static cenario1 + #122, #0
  static cenario1 + #123, #0
  static cenario1 + #124, #0
  static cenario1 + #125, #0
  static cenario1 + #126, #0
  static cenario1 + #127, #0
  static cenario1 + #128, #0
  static cenario1 + #129, #0
  static cenario1 + #130, #0
  static cenario1 + #131, #1536
  static cenario1 + #132, #1536
  static cenario1 + #133, #1536
  static cenario1 + #134, #1536
  static cenario1 + #135, #1536
  static cenario1 + #136, #1536
  static cenario1 + #137, #1536
  static cenario1 + #138, #1536
  static cenario1 + #139, #1536
  static cenario1 + #140, #1536
  static cenario1 + #141, #1536
  static cenario1 + #142, #1536
  static cenario1 + #143, #1536
  static cenario1 + #144, #1536
  static cenario1 + #145, #0
  static cenario1 + #146, #0
  static cenario1 + #147, #0
  static cenario1 + #148, #0
  static cenario1 + #149, #0
  static cenario1 + #150, #0
  static cenario1 + #151, #0
  static cenario1 + #152, #0
  static cenario1 + #153, #0
  static cenario1 + #154, #0
  static cenario1 + #155, #1536
  static cenario1 + #156, #1536
  static cenario1 + #157, #1536
  static cenario1 + #158, #1536
  static cenario1 + #159, #1536

  ;Linha 4
  static cenario1 + #160, #1536
  static cenario1 + #161, #0
  static cenario1 + #162, #0
  static cenario1 + #163, #0
  static cenario1 + #164, #0
  static cenario1 + #165, #0
  static cenario1 + #166, #0
  static cenario1 + #167, #0
  static cenario1 + #168, #0
  static cenario1 + #169, #0
  static cenario1 + #170, #0
  static cenario1 + #171, #1536
  static cenario1 + #172, #1536
  static cenario1 + #173, #1536
  static cenario1 + #174, #1536
  static cenario1 + #175, #1536
  static cenario1 + #176, #1536
  static cenario1 + #177, #1536
  static cenario1 + #178, #1536
  static cenario1 + #179, #1536
  static cenario1 + #180, #1536
  static cenario1 + #181, #1536
  static cenario1 + #182, #1536
  static cenario1 + #183, #1536
  static cenario1 + #184, #1536
  static cenario1 + #185, #0
  static cenario1 + #186, #0
  static cenario1 + #187, #0
  static cenario1 + #188, #0
  static cenario1 + #189, #0
  static cenario1 + #190, #0
  static cenario1 + #191, #0
  static cenario1 + #192, #0
  static cenario1 + #193, #0
  static cenario1 + #194, #1536
  static cenario1 + #195, #1536
  static cenario1 + #196, #1536
  static cenario1 + #197, #1536
  static cenario1 + #198, #1536
  static cenario1 + #199, #1536

  ;Linha 5
  static cenario1 + #200, #1536
  static cenario1 + #201, #1536
  static cenario1 + #202, #1536
  static cenario1 + #203, #0
  static cenario1 + #204, #0
  static cenario1 + #205, #0
  static cenario1 + #206, #0
  static cenario1 + #207, #0
  static cenario1 + #208, #0
  static cenario1 + #209, #1536
  static cenario1 + #210, #1536
  static cenario1 + #211, #1536
  static cenario1 + #212, #1536
  static cenario1 + #213, #1536
  static cenario1 + #214, #1536
  static cenario1 + #215, #1536
  static cenario1 + #216, #1536
  static cenario1 + #217, #1536
  static cenario1 + #218, #1536
  static cenario1 + #219, #1536
  static cenario1 + #220, #1536
  static cenario1 + #221, #1536
  static cenario1 + #222, #1536
  static cenario1 + #223, #1536
  static cenario1 + #224, #1536
  static cenario1 + #225, #1536
  static cenario1 + #226, #0
  static cenario1 + #227, #0
  static cenario1 + #228, #0
  static cenario1 + #229, #0
  static cenario1 + #230, #0
  static cenario1 + #231, #0
  static cenario1 + #232, #0
  static cenario1 + #233, #1536
  static cenario1 + #234, #1536
  static cenario1 + #235, #1536
  static cenario1 + #236, #1536
  static cenario1 + #237, #1536
  static cenario1 + #238, #1536
  static cenario1 + #239, #1536

  ;Linha 6
  static cenario1 + #240, #1536
  static cenario1 + #241, #1536
  static cenario1 + #242, #1536
  static cenario1 + #243, #1536
  static cenario1 + #244, #1536
  static cenario1 + #245, #0
  static cenario1 + #246, #0
  static cenario1 + #247, #0
  static cenario1 + #248, #1536
  static cenario1 + #249, #1536
  static cenario1 + #250, #1536
  static cenario1 + #251, #1536
  static cenario1 + #252, #1536
  static cenario1 + #253, #1536
  static cenario1 + #254, #1536
  static cenario1 + #255, #1536
  static cenario1 + #256, #1536
  static cenario1 + #257, #1536
  static cenario1 + #258, #1536
  static cenario1 + #259, #1536
  static cenario1 + #260, #1536
  static cenario1 + #261, #1536
  static cenario1 + #262, #1536
  static cenario1 + #263, #1536
  static cenario1 + #264, #1536
  static cenario1 + #265, #1536
  static cenario1 + #266, #1536
  static cenario1 + #267, #1536
  static cenario1 + #268, #0
  static cenario1 + #269, #0
  static cenario1 + #270, #0
  static cenario1 + #271, #0
  static cenario1 + #272, #1536
  static cenario1 + #273, #1536
  static cenario1 + #274, #1536
  static cenario1 + #275, #1536
  static cenario1 + #276, #1536
  static cenario1 + #277, #1536
  static cenario1 + #278, #1536
  static cenario1 + #279, #1536

  ;Linha 7
  static cenario1 + #280, #1536
  static cenario1 + #281, #1536
  static cenario1 + #282, #1536
  static cenario1 + #283, #1536
  static cenario1 + #284, #1536
  static cenario1 + #285, #1536
  static cenario1 + #286, #1536
  static cenario1 + #287, #1536
  static cenario1 + #288, #1536
  static cenario1 + #289, #1536
  static cenario1 + #290, #1536
  static cenario1 + #291, #1536
  static cenario1 + #292, #1536
  static cenario1 + #293, #1536
  static cenario1 + #294, #1536
  static cenario1 + #295, #1536
  static cenario1 + #296, #1536
  static cenario1 + #297, #1536
  static cenario1 + #298, #1536
  static cenario1 + #299, #1536
  static cenario1 + #300, #1536
  static cenario1 + #301, #1536
  static cenario1 + #302, #1536
  static cenario1 + #303, #1536
  static cenario1 + #304, #1536
  static cenario1 + #305, #1536
  static cenario1 + #306, #1536
  static cenario1 + #307, #1536
  static cenario1 + #308, #1536
  static cenario1 + #309, #1536
  static cenario1 + #310, #1536
  static cenario1 + #311, #1536
  static cenario1 + #312, #1536
  static cenario1 + #313, #1536
  static cenario1 + #314, #1536
  static cenario1 + #315, #1536
  static cenario1 + #316, #1536
  static cenario1 + #317, #1536
  static cenario1 + #318, #1536
  static cenario1 + #319, #1536

  ;Linha 8
  static cenario1 + #320, #1536
  static cenario1 + #321, #1536
  static cenario1 + #322, #1536
  static cenario1 + #323, #1536
  static cenario1 + #324, #1536
  static cenario1 + #325, #1536
  static cenario1 + #326, #1536
  static cenario1 + #327, #1536
  static cenario1 + #328, #1536
  static cenario1 + #329, #1536
  static cenario1 + #330, #1536
  static cenario1 + #331, #1536
  static cenario1 + #332, #1536
  static cenario1 + #333, #1536
  static cenario1 + #334, #1536
  static cenario1 + #335, #1536
  static cenario1 + #336, #1536
  static cenario1 + #337, #1536
  static cenario1 + #338, #1536
  static cenario1 + #339, #1536
  static cenario1 + #340, #1536
  static cenario1 + #341, #1536
  static cenario1 + #342, #1536
  static cenario1 + #343, #1536
  static cenario1 + #344, #1536
  static cenario1 + #345, #1536
  static cenario1 + #346, #1536
  static cenario1 + #347, #1536
  static cenario1 + #348, #1536
  static cenario1 + #349, #1536
  static cenario1 + #350, #1536
  static cenario1 + #351, #1536
  static cenario1 + #352, #1536
  static cenario1 + #353, #1536
  static cenario1 + #354, #1536
  static cenario1 + #355, #1536
  static cenario1 + #356, #1536
  static cenario1 + #357, #1536
  static cenario1 + #358, #1536
  static cenario1 + #359, #1536

  ;Linha 9
  static cenario1 + #360, #1536
  static cenario1 + #361, #1536
  static cenario1 + #362, #1536
  static cenario1 + #363, #768
  static cenario1 + #364, #768
  static cenario1 + #365, #768
  static cenario1 + #366, #1536
  static cenario1 + #367, #1536
  static cenario1 + #368, #1536
  static cenario1 + #369, #1536
  static cenario1 + #370, #1536
  static cenario1 + #371, #1536
  static cenario1 + #372, #1536
  static cenario1 + #373, #1536
  static cenario1 + #374, #1536
  static cenario1 + #375, #1536
  static cenario1 + #376, #1536
  static cenario1 + #377, #1536
  static cenario1 + #378, #1536
  static cenario1 + #379, #1536
  static cenario1 + #380, #1536
  static cenario1 + #381, #1536
  static cenario1 + #382, #1536
  static cenario1 + #383, #1536
  static cenario1 + #384, #1536
  static cenario1 + #385, #1536
  static cenario1 + #386, #1536
  static cenario1 + #387, #1536
  static cenario1 + #388, #1536
  static cenario1 + #389, #1536
  static cenario1 + #390, #1536
  static cenario1 + #391, #1536
  static cenario1 + #392, #1536
  static cenario1 + #393, #1536
  static cenario1 + #394, #1536
  static cenario1 + #395, #1536
  static cenario1 + #396, #1536
  static cenario1 + #397, #1536
  static cenario1 + #398, #1536
  static cenario1 + #399, #1536

  ;Linha 10
  static cenario1 + #400, #1536
  static cenario1 + #401, #1536
  static cenario1 + #402, #1536
  static cenario1 + #403, #768
  static cenario1 + #404, #768
  static cenario1 + #405, #768
  static cenario1 + #406, #768
  static cenario1 + #407, #1536
  static cenario1 + #408, #1536
  static cenario1 + #409, #1536
  static cenario1 + #410, #1536
  static cenario1 + #411, #1536
  static cenario1 + #412, #1536
  static cenario1 + #413, #1536
  static cenario1 + #414, #1536
  static cenario1 + #415, #1536
  static cenario1 + #416, #1536
  static cenario1 + #417, #1536
  static cenario1 + #418, #1536
  static cenario1 + #419, #1536
  static cenario1 + #420, #1536
  static cenario1 + #421, #1536
  static cenario1 + #422, #1536
  static cenario1 + #423, #1536
  static cenario1 + #424, #1536
  static cenario1 + #425, #1536
  static cenario1 + #426, #1536
  static cenario1 + #427, #1536
  static cenario1 + #428, #1536
  static cenario1 + #429, #1536
  static cenario1 + #430, #1536
  static cenario1 + #431, #1536
  static cenario1 + #432, #1536
  static cenario1 + #433, #1536
  static cenario1 + #434, #1536
  static cenario1 + #435, #1536
  static cenario1 + #436, #1536
  static cenario1 + #437, #1536
  static cenario1 + #438, #1536
  static cenario1 + #439, #1536

  ;Linha 11
  static cenario1 + #440, #1536
  static cenario1 + #441, #1536
  static cenario1 + #442, #768
  static cenario1 + #443, #768
  static cenario1 + #444, #2048
  static cenario1 + #445, #2048
  static cenario1 + #446, #1536
  static cenario1 + #447, #1536
  static cenario1 + #448, #1536
  static cenario1 + #449, #1536
  static cenario1 + #450, #1536
  static cenario1 + #451, #1536
  static cenario1 + #452, #1536
  static cenario1 + #453, #1536
  static cenario1 + #454, #1536
  static cenario1 + #455, #1536
  static cenario1 + #456, #1536
  static cenario1 + #457, #1536
  static cenario1 + #458, #1536
  static cenario1 + #459, #1536
  static cenario1 + #460, #1536
  static cenario1 + #461, #1536
  static cenario1 + #462, #1536
  static cenario1 + #463, #1536
  static cenario1 + #464, #1536
  static cenario1 + #465, #1536
  static cenario1 + #466, #1536
  static cenario1 + #467, #1536
  static cenario1 + #468, #1536
  static cenario1 + #469, #1536
  static cenario1 + #470, #1536
  static cenario1 + #471, #1536
  static cenario1 + #472, #1536
  static cenario1 + #473, #1536
  static cenario1 + #474, #1536
  static cenario1 + #475, #1536
  static cenario1 + #476, #1536
  static cenario1 + #477, #1536
  static cenario1 + #478, #1536
  static cenario1 + #479, #1536

  ;Linha 12
  static cenario1 + #480, #1536
  static cenario1 + #481, #1536
  static cenario1 + #482, #1536
  static cenario1 + #483, #1536
  static cenario1 + #484, #2048
  static cenario1 + #485, #1536
  static cenario1 + #486, #1536
  static cenario1 + #487, #1536
  static cenario1 + #488, #1536
  static cenario1 + #489, #1536
  static cenario1 + #490, #1536
  static cenario1 + #491, #1536
  static cenario1 + #492, #1536
  static cenario1 + #493, #1536
  static cenario1 + #494, #1536
  static cenario1 + #495, #1536
  static cenario1 + #496, #1536
  static cenario1 + #497, #1536
  static cenario1 + #498, #1536
  static cenario1 + #499, #1536
  static cenario1 + #500, #1536
  static cenario1 + #501, #1536
  static cenario1 + #502, #1536
  static cenario1 + #503, #1536
  static cenario1 + #504, #1536
  static cenario1 + #505, #1536
  static cenario1 + #506, #1536
  static cenario1 + #507, #1536
  static cenario1 + #508, #1536
  static cenario1 + #509, #1536
  static cenario1 + #510, #1536
  static cenario1 + #511, #1536
  static cenario1 + #512, #1536
  static cenario1 + #513, #1536
  static cenario1 + #514, #1536
  static cenario1 + #515, #1536
  static cenario1 + #516, #1536
  static cenario1 + #517, #1536
  static cenario1 + #518, #1536
  static cenario1 + #519, #1536

  ;Linha 13
  static cenario1 + #520, #1536
  static cenario1 + #521, #1536
  static cenario1 + #522, #768
  static cenario1 + #523, #768
  static cenario1 + #524, #2048
  static cenario1 + #525, #768
  static cenario1 + #526, #1536
  static cenario1 + #527, #1536
  static cenario1 + #528, #1536
  static cenario1 + #529, #1536
  static cenario1 + #530, #1536
  static cenario1 + #531, #1536
  static cenario1 + #532, #1536
  static cenario1 + #533, #1536
  static cenario1 + #534, #1536
  static cenario1 + #535, #1536
  static cenario1 + #536, #1536
  static cenario1 + #537, #1536
  static cenario1 + #538, #1536
  static cenario1 + #539, #1536
  static cenario1 + #540, #1536
  static cenario1 + #541, #1536
  static cenario1 + #542, #1536
  static cenario1 + #543, #1536
  static cenario1 + #544, #1536
  static cenario1 + #545, #1536
  static cenario1 + #546, #1536
  static cenario1 + #547, #1536
  static cenario1 + #548, #1536
  static cenario1 + #549, #1536
  static cenario1 + #550, #1536
  static cenario1 + #551, #1536
  static cenario1 + #552, #1536
  static cenario1 + #553, #1536
  static cenario1 + #554, #1536
  static cenario1 + #555, #1536
  static cenario1 + #556, #1536
  static cenario1 + #557, #1536
  static cenario1 + #558, #1536
  static cenario1 + #559, #1536

  ;Linha 14
  static cenario1 + #560, #1536
  static cenario1 + #561, #768
  static cenario1 + #562, #768
  static cenario1 + #563, #768
  static cenario1 + #564, #768
  static cenario1 + #565, #768
  static cenario1 + #566, #1536
  static cenario1 + #567, #1536
  static cenario1 + #568, #1536
  static cenario1 + #569, #1536
  static cenario1 + #570, #1536
  static cenario1 + #571, #1536
  static cenario1 + #572, #1536
  static cenario1 + #573, #1536
  static cenario1 + #574, #1536
  static cenario1 + #575, #1536
  static cenario1 + #576, #1536
  static cenario1 + #577, #1536
  static cenario1 + #578, #1536
  static cenario1 + #579, #1536
  static cenario1 + #580, #1536
  static cenario1 + #581, #1536
  static cenario1 + #582, #1536
  static cenario1 + #583, #1536
  static cenario1 + #584, #1536
  static cenario1 + #585, #1536
  static cenario1 + #586, #1536
  static cenario1 + #587, #1536
  static cenario1 + #588, #1536
  static cenario1 + #589, #1536
  static cenario1 + #590, #1536
  static cenario1 + #591, #1536
  static cenario1 + #592, #1536
  static cenario1 + #593, #1536
  static cenario1 + #594, #1536
  static cenario1 + #595, #1536
  static cenario1 + #596, #1536
  static cenario1 + #597, #1536
  static cenario1 + #598, #1536
  static cenario1 + #599, #1536

  ;Linha 15
  static cenario1 + #600, #768
  static cenario1 + #601, #768
  static cenario1 + #602, #768
  static cenario1 + #603, #768
  static cenario1 + #604, #768
  static cenario1 + #605, #768
  static cenario1 + #606, #768
  static cenario1 + #607, #768
  static cenario1 + #608, #2048
  static cenario1 + #609, #1536
  static cenario1 + #610, #1536
  static cenario1 + #611, #1536
  static cenario1 + #612, #1536
  static cenario1 + #613, #1536
  static cenario1 + #614, #1536
  static cenario1 + #615, #1536
  static cenario1 + #616, #1536
  static cenario1 + #617, #1536
  static cenario1 + #618, #1536
  static cenario1 + #619, #1536
  static cenario1 + #620, #1536
  static cenario1 + #621, #1536
  static cenario1 + #622, #1536
  static cenario1 + #623, #1536
  static cenario1 + #624, #1536
  static cenario1 + #625, #1536
  static cenario1 + #626, #1536
  static cenario1 + #627, #1536
  static cenario1 + #628, #1536
  static cenario1 + #629, #1536
  static cenario1 + #630, #1536
  static cenario1 + #631, #1536
  static cenario1 + #632, #1536
  static cenario1 + #633, #1536
  static cenario1 + #634, #1536
  static cenario1 + #635, #1536
  static cenario1 + #636, #1536
  static cenario1 + #637, #1536
  static cenario1 + #638, #1536
  static cenario1 + #639, #1536

  ;Linha 16
  static cenario1 + #640, #768
  static cenario1 + #641, #1536
  static cenario1 + #642, #768
  static cenario1 + #643, #768
  static cenario1 + #644, #768
  static cenario1 + #645, #768
  static cenario1 + #646, #1536
  static cenario1 + #647, #1536
  static cenario1 + #648, #1536
  static cenario1 + #649, #1536
  static cenario1 + #650, #1536
  static cenario1 + #651, #1536
  static cenario1 + #652, #1536
  static cenario1 + #653, #1536
  static cenario1 + #654, #1536
  static cenario1 + #655, #1536
  static cenario1 + #656, #1536
  static cenario1 + #657, #1536
  static cenario1 + #658, #1536
  static cenario1 + #659, #1536
  static cenario1 + #660, #1536
  static cenario1 + #661, #1536
  static cenario1 + #662, #1536
  static cenario1 + #663, #1536
  static cenario1 + #664, #1536
  static cenario1 + #665, #1536
  static cenario1 + #666, #1536
  static cenario1 + #667, #1536
  static cenario1 + #668, #1536
  static cenario1 + #669, #1536
  static cenario1 + #670, #1536
  static cenario1 + #671, #1536
  static cenario1 + #672, #1536
  static cenario1 + #673, #1536
  static cenario1 + #674, #1536
  static cenario1 + #675, #1536
  static cenario1 + #676, #1536
  static cenario1 + #677, #1536
  static cenario1 + #678, #1536
  static cenario1 + #679, #1536

  ;Linha 17
  static cenario1 + #680, #2048
  static cenario1 + #681, #1536
  static cenario1 + #682, #768
  static cenario1 + #683, #768
  static cenario1 + #684, #768
  static cenario1 + #685, #768
  static cenario1 + #686, #768
  static cenario1 + #687, #1536
  static cenario1 + #688, #1536
  static cenario1 + #689, #1536
  static cenario1 + #690, #1536
  static cenario1 + #691, #1536
  static cenario1 + #692, #1536
  static cenario1 + #693, #1536
  static cenario1 + #694, #1536
  static cenario1 + #695, #1536
  static cenario1 + #696, #1536
  static cenario1 + #697, #1536
  static cenario1 + #698, #1536
  static cenario1 + #699, #1536
  static cenario1 + #700, #1536
  static cenario1 + #701, #1536
  static cenario1 + #702, #1536
  static cenario1 + #703, #1536
  static cenario1 + #704, #1536
  static cenario1 + #705, #1536
  static cenario1 + #706, #1536
  static cenario1 + #707, #1536
  static cenario1 + #708, #1536
  static cenario1 + #709, #1536
  static cenario1 + #710, #1536
  static cenario1 + #711, #1536
  static cenario1 + #712, #1536
  static cenario1 + #713, #1536
  static cenario1 + #714, #1536
  static cenario1 + #715, #1536
  static cenario1 + #716, #1536
  static cenario1 + #717, #1536
  static cenario1 + #718, #1536
  static cenario1 + #719, #1536

  ;Linha 18
  static cenario1 + #720, #1536
  static cenario1 + #721, #1536
  static cenario1 + #722, #768
  static cenario1 + #723, #1536
  static cenario1 + #724, #1536
  static cenario1 + #725, #1536
  static cenario1 + #726, #768
  static cenario1 + #727, #1536
  static cenario1 + #728, #1536
  static cenario1 + #729, #1536
  static cenario1 + #730, #1536
  static cenario1 + #731, #1536
  static cenario1 + #732, #1536
  static cenario1 + #733, #1536
  static cenario1 + #734, #1536
  static cenario1 + #735, #1536
  static cenario1 + #736, #1536
  static cenario1 + #737, #1536
  static cenario1 + #738, #1536
  static cenario1 + #739, #1536
  static cenario1 + #740, #1536
  static cenario1 + #741, #1536
  static cenario1 + #742, #1536
  static cenario1 + #743, #1536
  static cenario1 + #744, #1536
  static cenario1 + #745, #1536
  static cenario1 + #746, #1536
  static cenario1 + #747, #1536
  static cenario1 + #748, #1536
  static cenario1 + #749, #1536
  static cenario1 + #750, #1536
  static cenario1 + #751, #1536
  static cenario1 + #752, #1536
  static cenario1 + #753, #1536
  static cenario1 + #754, #1536
  static cenario1 + #755, #1536
  static cenario1 + #756, #1536
  static cenario1 + #757, #1536
  static cenario1 + #758, #1536
  static cenario1 + #759, #1536

  ;Linha 19
  static cenario1 + #760, #1536
  static cenario1 + #761, #1536
  static cenario1 + #762, #768
  static cenario1 + #763, #1536
  static cenario1 + #764, #1536
  static cenario1 + #765, #1536
  static cenario1 + #766, #768
  static cenario1 + #767, #1536
  static cenario1 + #768, #1536
  static cenario1 + #769, #1536
  static cenario1 + #770, #1536
  static cenario1 + #771, #1536
  static cenario1 + #772, #1536
  static cenario1 + #773, #1536
  static cenario1 + #774, #1536
  static cenario1 + #775, #1536
  static cenario1 + #776, #1536
  static cenario1 + #777, #1536
  static cenario1 + #778, #1536
  static cenario1 + #779, #1536
  static cenario1 + #780, #1536
  static cenario1 + #781, #1536
  static cenario1 + #782, #1536
  static cenario1 + #783, #1536
  static cenario1 + #784, #1536
  static cenario1 + #785, #1536
  static cenario1 + #786, #1536
  static cenario1 + #787, #1536
  static cenario1 + #788, #1536
  static cenario1 + #789, #1536
  static cenario1 + #790, #1536
  static cenario1 + #791, #1536
  static cenario1 + #792, #1536
  static cenario1 + #793, #1536
  static cenario1 + #794, #1536
  static cenario1 + #795, #1536
  static cenario1 + #796, #1536
  static cenario1 + #797, #1536
  static cenario1 + #798, #1536
  static cenario1 + #799, #1536

  ;Linha 20
  static cenario1 + #800, #1536
  static cenario1 + #801, #1536
  static cenario1 + #802, #768
  static cenario1 + #803, #768
  static cenario1 + #804, #1536
  static cenario1 + #805, #1536
  static cenario1 + #806, #768
  static cenario1 + #807, #768
  static cenario1 + #808, #1536
  static cenario1 + #809, #1536
  static cenario1 + #810, #1536
  static cenario1 + #811, #1536
  static cenario1 + #812, #1536
  static cenario1 + #813, #1536
  static cenario1 + #814, #1536
  static cenario1 + #815, #1536
  static cenario1 + #816, #1536
  static cenario1 + #817, #1536
  static cenario1 + #818, #1536
  static cenario1 + #819, #1536
  static cenario1 + #820, #1536
  static cenario1 + #821, #1536
  static cenario1 + #822, #1536
  static cenario1 + #823, #1536
  static cenario1 + #824, #1536
  static cenario1 + #825, #1536
  static cenario1 + #826, #1536
  static cenario1 + #827, #1536
  static cenario1 + #828, #1536
  static cenario1 + #829, #1536
  static cenario1 + #830, #1536
  static cenario1 + #831, #1536
  static cenario1 + #832, #1536
  static cenario1 + #833, #1536
  static cenario1 + #834, #1536
  static cenario1 + #835, #1536
  static cenario1 + #836, #1536
  static cenario1 + #837, #1536
  static cenario1 + #838, #1536
  static cenario1 + #839, #1536

  ;Linha 21
  static cenario1 + #840, #2560
  static cenario1 + #841, #2560
  static cenario1 + #842, #2560
  static cenario1 + #843, #2560
  static cenario1 + #844, #2560
  static cenario1 + #845, #2560
  static cenario1 + #846, #2560
  static cenario1 + #847, #2560
  static cenario1 + #848, #2560
  static cenario1 + #849, #2560
  static cenario1 + #850, #2560
  static cenario1 + #851, #2560
  static cenario1 + #852, #2305
  static cenario1 + #853, #2560
  static cenario1 + #854, #2305
  static cenario1 + #855, #2560
  static cenario1 + #856, #2560
  static cenario1 + #857, #2560
  static cenario1 + #858, #2560
  static cenario1 + #859, #2560
  static cenario1 + #860, #2560
  static cenario1 + #861, #2305
  static cenario1 + #862, #2560
  static cenario1 + #863, #2305
  static cenario1 + #864, #2560
  static cenario1 + #865, #2560
  static cenario1 + #866, #2560
  static cenario1 + #867, #2560
  static cenario1 + #868, #2560
  static cenario1 + #869, #2305
  static cenario1 + #870, #2560
  static cenario1 + #871, #2560
  static cenario1 + #872, #2560
  static cenario1 + #873, #2560
  static cenario1 + #874, #2305
  static cenario1 + #875, #2560
  static cenario1 + #876, #2560
  static cenario1 + #877, #2305
  static cenario1 + #878, #2560
  static cenario1 + #879, #2560

  ;Linha 22
  static cenario1 + #880, #2560
  static cenario1 + #881, #2560
  static cenario1 + #882, #256
  static cenario1 + #883, #256
  static cenario1 + #884, #2560
  static cenario1 + #885, #256
  static cenario1 + #886, #2560
  static cenario1 + #887, #256
  static cenario1 + #888, #2560
  static cenario1 + #889, #2560
  static cenario1 + #890, #256
  static cenario1 + #891, #2560
  static cenario1 + #892, #256
  static cenario1 + #893, #256
  static cenario1 + #894, #2560
  static cenario1 + #895, #2560
  static cenario1 + #896, #256
  static cenario1 + #897, #256
  static cenario1 + #898, #256
  static cenario1 + #899, #2560
  static cenario1 + #900, #2560
  static cenario1 + #901, #2560
  static cenario1 + #902, #256
  static cenario1 + #903, #256
  static cenario1 + #904, #2560
  static cenario1 + #905, #256
  static cenario1 + #906, #256
  static cenario1 + #907, #256
  static cenario1 + #908, #2560
  static cenario1 + #909, #2560
  static cenario1 + #910, #2560
  static cenario1 + #911, #2560
  static cenario1 + #912, #256
  static cenario1 + #913, #2560
  static cenario1 + #914, #256
  static cenario1 + #915, #2560
  static cenario1 + #916, #2560
  static cenario1 + #917, #256
  static cenario1 + #918, #2560
  static cenario1 + #919, #256

  ;Linha 23
  static cenario1 + #920, #256
  static cenario1 + #921, #256
  static cenario1 + #922, #256
  static cenario1 + #923, #2560
  static cenario1 + #924, #256
  static cenario1 + #925, #256
  static cenario1 + #926, #256
  static cenario1 + #927, #256
  static cenario1 + #928, #2560
  static cenario1 + #929, #256
  static cenario1 + #930, #2560
  static cenario1 + #931, #256
  static cenario1 + #932, #2560
  static cenario1 + #933, #2560
  static cenario1 + #934, #256
  static cenario1 + #935, #256
  static cenario1 + #936, #2560
  static cenario1 + #937, #2560
  static cenario1 + #938, #256
  static cenario1 + #939, #256
  static cenario1 + #940, #256
  static cenario1 + #941, #256
  static cenario1 + #942, #2560
  static cenario1 + #943, #2560
  static cenario1 + #944, #256
  static cenario1 + #945, #2560
  static cenario1 + #946, #256
  static cenario1 + #947, #2560
  static cenario1 + #948, #256
  static cenario1 + #949, #256
  static cenario1 + #950, #256
  static cenario1 + #951, #256
  static cenario1 + #952, #256
  static cenario1 + #953, #256
  static cenario1 + #954, #2560
  static cenario1 + #955, #256
  static cenario1 + #956, #256
  static cenario1 + #957, #256
  static cenario1 + #958, #256
  static cenario1 + #959, #2560

  ;Linha 24
  static cenario1 + #960, #256
  static cenario1 + #961, #256
  static cenario1 + #962, #256
  static cenario1 + #963, #256
  static cenario1 + #964, #256
  static cenario1 + #965, #256
  static cenario1 + #966, #256
  static cenario1 + #967, #256
  static cenario1 + #968, #256
  static cenario1 + #969, #256
  static cenario1 + #970, #256
  static cenario1 + #971, #256
  static cenario1 + #972, #256
  static cenario1 + #973, #256
  static cenario1 + #974, #256
  static cenario1 + #975, #256
  static cenario1 + #976, #256
  static cenario1 + #977, #256
  static cenario1 + #978, #256
  static cenario1 + #979, #256
  static cenario1 + #980, #256
  static cenario1 + #981, #256
  static cenario1 + #982, #256
  static cenario1 + #983, #256
  static cenario1 + #984, #256
  static cenario1 + #985, #256
  static cenario1 + #986, #256
  static cenario1 + #987, #256
  static cenario1 + #988, #256
  static cenario1 + #989, #256
  static cenario1 + #990, #256
  static cenario1 + #991, #256
  static cenario1 + #992, #256
  static cenario1 + #993, #256
  static cenario1 + #994, #256
  static cenario1 + #995, #256
  static cenario1 + #996, #256
  static cenario1 + #997, #256
  static cenario1 + #998, #256
  static cenario1 + #999, #256

  ;Linha 25
  static cenario1 + #1000, #256
  static cenario1 + #1001, #256
  static cenario1 + #1002, #256
  static cenario1 + #1003, #256
  static cenario1 + #1004, #256
  static cenario1 + #1005, #256
  static cenario1 + #1006, #256
  static cenario1 + #1007, #256
  static cenario1 + #1008, #256
  static cenario1 + #1009, #256
  static cenario1 + #1010, #256
  static cenario1 + #1011, #256
  static cenario1 + #1012, #256
  static cenario1 + #1013, #256
  static cenario1 + #1014, #256
  static cenario1 + #1015, #256
  static cenario1 + #1016, #256
  static cenario1 + #1017, #256
  static cenario1 + #1018, #256
  static cenario1 + #1019, #256
  static cenario1 + #1020, #256
  static cenario1 + #1021, #256
  static cenario1 + #1022, #256
  static cenario1 + #1023, #256
  static cenario1 + #1024, #256
  static cenario1 + #1025, #256
  static cenario1 + #1026, #256
  static cenario1 + #1027, #256
  static cenario1 + #1028, #256
  static cenario1 + #1029, #256
  static cenario1 + #1030, #256
  static cenario1 + #1031, #256
  static cenario1 + #1032, #256
  static cenario1 + #1033, #256
  static cenario1 + #1034, #256
  static cenario1 + #1035, #256
  static cenario1 + #1036, #256
  static cenario1 + #1037, #256
  static cenario1 + #1038, #256
  static cenario1 + #1039, #256

  ;Linha 26
  static cenario1 + #1040, #256
  static cenario1 + #1041, #256
  static cenario1 + #1042, #256
  static cenario1 + #1043, #256
  static cenario1 + #1044, #256
  static cenario1 + #1045, #256
  static cenario1 + #1046, #256
  static cenario1 + #1047, #256
  static cenario1 + #1048, #256
  static cenario1 + #1049, #256
  static cenario1 + #1050, #256
  static cenario1 + #1051, #256
  static cenario1 + #1052, #256
  static cenario1 + #1053, #256
  static cenario1 + #1054, #256
  static cenario1 + #1055, #256
  static cenario1 + #1056, #256
  static cenario1 + #1057, #256
  static cenario1 + #1058, #256
  static cenario1 + #1059, #256
  static cenario1 + #1060, #256
  static cenario1 + #1061, #256
  static cenario1 + #1062, #256
  static cenario1 + #1063, #256
  static cenario1 + #1064, #256
  static cenario1 + #1065, #256
  static cenario1 + #1066, #256
  static cenario1 + #1067, #256
  static cenario1 + #1068, #256
  static cenario1 + #1069, #256
  static cenario1 + #1070, #256
  static cenario1 + #1071, #256
  static cenario1 + #1072, #256
  static cenario1 + #1073, #256
  static cenario1 + #1074, #256
  static cenario1 + #1075, #256
  static cenario1 + #1076, #256
  static cenario1 + #1077, #256
  static cenario1 + #1078, #256
  static cenario1 + #1079, #256

  ;Linha 27
  static cenario1 + #1080, #256
  static cenario1 + #1081, #256
  static cenario1 + #1082, #256
  static cenario1 + #1083, #256
  static cenario1 + #1084, #256
  static cenario1 + #1085, #256
  static cenario1 + #1086, #256
  static cenario1 + #1087, #256
  static cenario1 + #1088, #256
  static cenario1 + #1089, #256
  static cenario1 + #1090, #256
  static cenario1 + #1091, #256
  static cenario1 + #1092, #256
  static cenario1 + #1093, #256
  static cenario1 + #1094, #256
  static cenario1 + #1095, #256
  static cenario1 + #1096, #256
  static cenario1 + #1097, #256
  static cenario1 + #1098, #256
  static cenario1 + #1099, #256
  static cenario1 + #1100, #256
  static cenario1 + #1101, #256
  static cenario1 + #1102, #256
  static cenario1 + #1103, #256
  static cenario1 + #1104, #256
  static cenario1 + #1105, #256
  static cenario1 + #1106, #256
  static cenario1 + #1107, #256
  static cenario1 + #1108, #256
  static cenario1 + #1109, #256
  static cenario1 + #1110, #256
  static cenario1 + #1111, #256
  static cenario1 + #1112, #256
  static cenario1 + #1113, #256
  static cenario1 + #1114, #256
  static cenario1 + #1115, #256
  static cenario1 + #1116, #256
  static cenario1 + #1117, #256
  static cenario1 + #1118, #256
  static cenario1 + #1119, #256

  ;Linha 28
  static cenario1 + #1120, #256
  static cenario1 + #1121, #256
  static cenario1 + #1122, #256
  static cenario1 + #1123, #256
  static cenario1 + #1124, #256
  static cenario1 + #1125, #256
  static cenario1 + #1126, #256
  static cenario1 + #1127, #256
  static cenario1 + #1128, #256
  static cenario1 + #1129, #256
  static cenario1 + #1130, #256
  static cenario1 + #1131, #256
  static cenario1 + #1132, #256
  static cenario1 + #1133, #256
  static cenario1 + #1134, #256
  static cenario1 + #1135, #256
  static cenario1 + #1136, #256
  static cenario1 + #1137, #256
  static cenario1 + #1138, #256
  static cenario1 + #1139, #256
  static cenario1 + #1140, #256
  static cenario1 + #1141, #256
  static cenario1 + #1142, #256
  static cenario1 + #1143, #256
  static cenario1 + #1144, #256
  static cenario1 + #1145, #256
  static cenario1 + #1146, #256
  static cenario1 + #1147, #256
  static cenario1 + #1148, #256
  static cenario1 + #1149, #256
  static cenario1 + #1150, #256
  static cenario1 + #1151, #256
  static cenario1 + #1152, #256
  static cenario1 + #1153, #256
  static cenario1 + #1154, #256
  static cenario1 + #1155, #256
  static cenario1 + #1156, #256
  static cenario1 + #1157, #256
  static cenario1 + #1158, #256
  static cenario1 + #1159, #256

  ;Linha 29
  static cenario1 + #1160, #256
  static cenario1 + #1161, #256
  static cenario1 + #1162, #256
  static cenario1 + #1163, #256
  static cenario1 + #1164, #256
  static cenario1 + #1165, #256
  static cenario1 + #1166, #256
  static cenario1 + #1167, #256
  static cenario1 + #1168, #256
  static cenario1 + #1169, #256
  static cenario1 + #1170, #256
  static cenario1 + #1171, #256
  static cenario1 + #1172, #256
  static cenario1 + #1173, #256
  static cenario1 + #1174, #256
  static cenario1 + #1175, #256
  static cenario1 + #1176, #256
  static cenario1 + #1177, #256
  static cenario1 + #1178, #256
  static cenario1 + #1179, #256
  static cenario1 + #1180, #256
  static cenario1 + #1181, #256
  static cenario1 + #1182, #256
  static cenario1 + #1183, #256
  static cenario1 + #1184, #256
  static cenario1 + #1185, #256
  static cenario1 + #1186, #256
  static cenario1 + #1187, #256
  static cenario1 + #1188, #256
  static cenario1 + #1189, #256
  static cenario1 + #1190, #256
  static cenario1 + #1191, #256
  static cenario1 + #1192, #256
  static cenario1 + #1193, #256
  static cenario1 + #1194, #256
  static cenario1 + #1195, #256
  static cenario1 + #1196, #256
  static cenario1 + #1197, #256
  static cenario1 + #1198, #256
  static cenario1 + #1199, #256

printcenario1Screen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #cenario1
  loadn R1, #0
  loadn R2, #1200

  printcenario1ScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printcenario1ScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts


; ===========================================================
; TABULEIRO 100
; ===========================================================

tabuleiro100 : var #1200
  ;Linha 0
  static tabuleiro100 + #0, #1536
  static tabuleiro100 + #1, #1536
  static tabuleiro100 + #2, #1536
  static tabuleiro100 + #3, #1536
  static tabuleiro100 + #4, #1536
  static tabuleiro100 + #5, #1536
  static tabuleiro100 + #6, #1536
  static tabuleiro100 + #7, #1536
  static tabuleiro100 + #8, #1536
  static tabuleiro100 + #9, #1536
  static tabuleiro100 + #10, #1280
  static tabuleiro100 + #11, #1280
  static tabuleiro100 + #12, #1280
  static tabuleiro100 + #13, #1280
  static tabuleiro100 + #14, #1280
  static tabuleiro100 + #15, #1280
  static tabuleiro100 + #16, #1280
  static tabuleiro100 + #17, #1280
  static tabuleiro100 + #18, #1280
  static tabuleiro100 + #19, #1280
  static tabuleiro100 + #20, #1280
  static tabuleiro100 + #21, #1280
  static tabuleiro100 + #22, #1280
  static tabuleiro100 + #23, #1280
  static tabuleiro100 + #24, #1280
  static tabuleiro100 + #25, #1280
  static tabuleiro100 + #26, #1280
  static tabuleiro100 + #27, #1280
  static tabuleiro100 + #28, #1280
  static tabuleiro100 + #29, #1280
  static tabuleiro100 + #30, #0
  static tabuleiro100 + #31, #1536
  static tabuleiro100 + #32, #1536
  static tabuleiro100 + #33, #1536
  static tabuleiro100 + #34, #1536
  static tabuleiro100 + #35, #1536
  static tabuleiro100 + #36, #1536
  static tabuleiro100 + #37, #1536
  static tabuleiro100 + #38, #1536
  static tabuleiro100 + #39, #1536

  ;Linha 1
  static tabuleiro100 + #40, #1536
  static tabuleiro100 + #41, #1536
  static tabuleiro100 + #42, #1536
  static tabuleiro100 + #43, #1536
  static tabuleiro100 + #44, #0
  static tabuleiro100 + #45, #0
  static tabuleiro100 + #46, #0
  static tabuleiro100 + #47, #1536
  static tabuleiro100 + #48, #1536
  static tabuleiro100 + #49, #1280
  static tabuleiro100 + #50, #1280
  static tabuleiro100 + #51, #1280
  static tabuleiro100 + #52, #1280
  static tabuleiro100 + #53, #1280
  static tabuleiro100 + #54, #1280
  static tabuleiro100 + #55, #1280
  static tabuleiro100 + #56, #1280
  static tabuleiro100 + #57, #1280
  static tabuleiro100 + #58, #1280
  static tabuleiro100 + #59, #1280
  static tabuleiro100 + #60, #1280
  static tabuleiro100 + #61, #1280
  static tabuleiro100 + #62, #1280
  static tabuleiro100 + #63, #1280
  static tabuleiro100 + #64, #1280
  static tabuleiro100 + #65, #1280
  static tabuleiro100 + #66, #1280
  static tabuleiro100 + #67, #1280
  static tabuleiro100 + #68, #1280
  static tabuleiro100 + #69, #1280
  static tabuleiro100 + #70, #1280
  static tabuleiro100 + #71, #0
  static tabuleiro100 + #72, #1536
  static tabuleiro100 + #73, #1536
  static tabuleiro100 + #74, #1536
  static tabuleiro100 + #75, #1536
  static tabuleiro100 + #76, #1536
  static tabuleiro100 + #77, #1536
  static tabuleiro100 + #78, #1536
  static tabuleiro100 + #79, #1536

  ;Linha 2
  static tabuleiro100 + #80, #1536
  static tabuleiro100 + #81, #1536
  static tabuleiro100 + #82, #0
  static tabuleiro100 + #83, #0
  static tabuleiro100 + #84, #0
  static tabuleiro100 + #85, #0
  static tabuleiro100 + #86, #0
  static tabuleiro100 + #87, #0
  static tabuleiro100 + #88, #1280
  static tabuleiro100 + #89, #1280
  static tabuleiro100 + #90, #1536
  static tabuleiro100 + #91, #1536
  static tabuleiro100 + #92, #1536
  static tabuleiro100 + #93, #1536
  static tabuleiro100 + #94, #1536
  static tabuleiro100 + #95, #1536
  static tabuleiro100 + #96, #1536
  static tabuleiro100 + #97, #1536
  static tabuleiro100 + #98, #1536
  static tabuleiro100 + #99, #1536
  static tabuleiro100 + #100, #1536
  static tabuleiro100 + #101, #1536
  static tabuleiro100 + #102, #1536
  static tabuleiro100 + #103, #1536
  static tabuleiro100 + #104, #1536
  static tabuleiro100 + #105, #1536
  static tabuleiro100 + #106, #0
  static tabuleiro100 + #107, #0
  static tabuleiro100 + #108, #0
  static tabuleiro100 + #109, #0
  static tabuleiro100 + #110, #1280
  static tabuleiro100 + #111, #1280
  static tabuleiro100 + #112, #0
  static tabuleiro100 + #113, #0
  static tabuleiro100 + #114, #1536
  static tabuleiro100 + #115, #1536
  static tabuleiro100 + #116, #1536
  static tabuleiro100 + #117, #1536
  static tabuleiro100 + #118, #1536
  static tabuleiro100 + #119, #1536

  ;Linha 3
  static tabuleiro100 + #120, #1536
  static tabuleiro100 + #121, #0
  static tabuleiro100 + #122, #0
  static tabuleiro100 + #123, #0
  static tabuleiro100 + #124, #0
  static tabuleiro100 + #125, #0
  static tabuleiro100 + #126, #0
  static tabuleiro100 + #127, #0
  static tabuleiro100 + #128, #1280
  static tabuleiro100 + #129, #1280
  static tabuleiro100 + #130, #0
  static tabuleiro100 + #131, #1536
  static tabuleiro100 + #132, #1536
  static tabuleiro100 + #133, #1536
  static tabuleiro100 + #134, #1536
  static tabuleiro100 + #135, #1536
  static tabuleiro100 + #136, #1536
  static tabuleiro100 + #137, #1536
  static tabuleiro100 + #138, #1536
  static tabuleiro100 + #139, #1536
  static tabuleiro100 + #140, #1536
  static tabuleiro100 + #141, #1536
  static tabuleiro100 + #142, #1536
  static tabuleiro100 + #143, #1536
  static tabuleiro100 + #144, #1536
  static tabuleiro100 + #145, #0
  static tabuleiro100 + #146, #0
  static tabuleiro100 + #147, #0
  static tabuleiro100 + #148, #0
  static tabuleiro100 + #149, #0
  static tabuleiro100 + #150, #1280
  static tabuleiro100 + #151, #1280
  static tabuleiro100 + #152, #0
  static tabuleiro100 + #153, #0
  static tabuleiro100 + #154, #0
  static tabuleiro100 + #155, #1536
  static tabuleiro100 + #156, #1536
  static tabuleiro100 + #157, #1536
  static tabuleiro100 + #158, #1536
  static tabuleiro100 + #159, #1536

  ;Linha 4
  static tabuleiro100 + #160, #1536
  static tabuleiro100 + #161, #0
  static tabuleiro100 + #162, #0
  static tabuleiro100 + #163, #0
  static tabuleiro100 + #164, #0
  static tabuleiro100 + #165, #0
  static tabuleiro100 + #166, #0
  static tabuleiro100 + #167, #0
  static tabuleiro100 + #168, #1280
  static tabuleiro100 + #169, #1280
  static tabuleiro100 + #170, #0
  static tabuleiro100 + #171, #1536
  static tabuleiro100 + #172, #1536
  static tabuleiro100 + #173, #1536
  static tabuleiro100 + #174, #1536
  static tabuleiro100 + #175, #1536
  static tabuleiro100 + #176, #1536
  static tabuleiro100 + #177, #1536
  static tabuleiro100 + #178, #1536
  static tabuleiro100 + #179, #1536
  static tabuleiro100 + #180, #1536
  static tabuleiro100 + #181, #1536
  static tabuleiro100 + #182, #1536
  static tabuleiro100 + #183, #1536
  static tabuleiro100 + #184, #1536
  static tabuleiro100 + #185, #0
  static tabuleiro100 + #186, #0
  static tabuleiro100 + #187, #0
  static tabuleiro100 + #188, #0
  static tabuleiro100 + #189, #0
  static tabuleiro100 + #190, #1280
  static tabuleiro100 + #191, #1280
  static tabuleiro100 + #192, #0
  static tabuleiro100 + #193, #0
  static tabuleiro100 + #194, #1536
  static tabuleiro100 + #195, #1536
  static tabuleiro100 + #196, #1536
  static tabuleiro100 + #197, #1536
  static tabuleiro100 + #198, #1536
  static tabuleiro100 + #199, #1536

  ;Linha 5
  static tabuleiro100 + #200, #1536
  static tabuleiro100 + #201, #1536
  static tabuleiro100 + #202, #1536
  static tabuleiro100 + #203, #0
  static tabuleiro100 + #204, #0
  static tabuleiro100 + #205, #0
  static tabuleiro100 + #206, #0
  static tabuleiro100 + #207, #0
  static tabuleiro100 + #208, #1280
  static tabuleiro100 + #209, #1280
  static tabuleiro100 + #210, #1536
  static tabuleiro100 + #211, #1536
  static tabuleiro100 + #212, #1536
  static tabuleiro100 + #213, #1536
  static tabuleiro100 + #214, #1536
  static tabuleiro100 + #215, #1536
  static tabuleiro100 + #216, #1536
  static tabuleiro100 + #217, #1536
  static tabuleiro100 + #218, #1536
  static tabuleiro100 + #219, #1536
  static tabuleiro100 + #220, #1536
  static tabuleiro100 + #221, #1536
  static tabuleiro100 + #222, #1536
  static tabuleiro100 + #223, #1536
  static tabuleiro100 + #224, #1536
  static tabuleiro100 + #225, #1536
  static tabuleiro100 + #226, #0
  static tabuleiro100 + #227, #0
  static tabuleiro100 + #228, #0
  static tabuleiro100 + #229, #0
  static tabuleiro100 + #230, #1280
  static tabuleiro100 + #231, #1280
  static tabuleiro100 + #232, #0
  static tabuleiro100 + #233, #1536
  static tabuleiro100 + #234, #1536
  static tabuleiro100 + #235, #1536
  static tabuleiro100 + #236, #1536
  static tabuleiro100 + #237, #1536
  static tabuleiro100 + #238, #1536
  static tabuleiro100 + #239, #1536

  ;Linha 6
  static tabuleiro100 + #240, #1536
  static tabuleiro100 + #241, #1536
  static tabuleiro100 + #242, #1536
  static tabuleiro100 + #243, #1536
  static tabuleiro100 + #244, #1536
  static tabuleiro100 + #245, #0
  static tabuleiro100 + #246, #0
  static tabuleiro100 + #247, #0
  static tabuleiro100 + #248, #1280
  static tabuleiro100 + #249, #1280
  static tabuleiro100 + #250, #1536
  static tabuleiro100 + #251, #1536
  static tabuleiro100 + #252, #1536
  static tabuleiro100 + #253, #1536
  static tabuleiro100 + #254, #1536
  static tabuleiro100 + #255, #1536
  static tabuleiro100 + #256, #1536
  static tabuleiro100 + #257, #1536
  static tabuleiro100 + #258, #1536
  static tabuleiro100 + #259, #1536
  static tabuleiro100 + #260, #1536
  static tabuleiro100 + #261, #1536
  static tabuleiro100 + #262, #1536
  static tabuleiro100 + #263, #1536
  static tabuleiro100 + #264, #1536
  static tabuleiro100 + #265, #1536
  static tabuleiro100 + #266, #1536
  static tabuleiro100 + #267, #1536
  static tabuleiro100 + #268, #0
  static tabuleiro100 + #269, #0
  static tabuleiro100 + #270, #1280
  static tabuleiro100 + #271, #1280
  static tabuleiro100 + #272, #1536
  static tabuleiro100 + #273, #1536
  static tabuleiro100 + #274, #1536
  static tabuleiro100 + #275, #1536
  static tabuleiro100 + #276, #1536
  static tabuleiro100 + #277, #1536
  static tabuleiro100 + #278, #1536
  static tabuleiro100 + #279, #1536

  ;Linha 7
  static tabuleiro100 + #280, #1536
  static tabuleiro100 + #281, #1536
  static tabuleiro100 + #282, #1536
  static tabuleiro100 + #283, #1536
  static tabuleiro100 + #284, #1536
  static tabuleiro100 + #285, #1536
  static tabuleiro100 + #286, #1536
  static tabuleiro100 + #287, #1536
  static tabuleiro100 + #288, #1280
  static tabuleiro100 + #289, #1280
  static tabuleiro100 + #290, #1536
  static tabuleiro100 + #291, #1536
  static tabuleiro100 + #292, #1536
  static tabuleiro100 + #293, #1536
  static tabuleiro100 + #294, #1536
  static tabuleiro100 + #295, #1536
  static tabuleiro100 + #296, #1536
  static tabuleiro100 + #297, #1536
  static tabuleiro100 + #298, #1536
  static tabuleiro100 + #299, #1536
  static tabuleiro100 + #300, #1536
  static tabuleiro100 + #301, #1536
  static tabuleiro100 + #302, #1536
  static tabuleiro100 + #303, #1536
  static tabuleiro100 + #304, #1536
  static tabuleiro100 + #305, #1536
  static tabuleiro100 + #306, #1536
  static tabuleiro100 + #307, #1536
  static tabuleiro100 + #308, #1536
  static tabuleiro100 + #309, #1536
  static tabuleiro100 + #310, #1280
  static tabuleiro100 + #311, #1280
  static tabuleiro100 + #312, #1536
  static tabuleiro100 + #313, #1536
  static tabuleiro100 + #314, #1536
  static tabuleiro100 + #315, #1536
  static tabuleiro100 + #316, #1536
  static tabuleiro100 + #317, #1536
  static tabuleiro100 + #318, #1536
  static tabuleiro100 + #319, #1536

  ;Linha 8
  static tabuleiro100 + #320, #1536
  static tabuleiro100 + #321, #1536
  static tabuleiro100 + #322, #1536
  static tabuleiro100 + #323, #1536
  static tabuleiro100 + #324, #1536
  static tabuleiro100 + #325, #1536
  static tabuleiro100 + #326, #1536
  static tabuleiro100 + #327, #1536
  static tabuleiro100 + #328, #1280
  static tabuleiro100 + #329, #1280
  static tabuleiro100 + #330, #1536
  static tabuleiro100 + #331, #1536
  static tabuleiro100 + #332, #1536
  static tabuleiro100 + #333, #1536
  static tabuleiro100 + #334, #1536
  static tabuleiro100 + #335, #1536
  static tabuleiro100 + #336, #1536
  static tabuleiro100 + #337, #1536
  static tabuleiro100 + #338, #1536
  static tabuleiro100 + #339, #1536
  static tabuleiro100 + #340, #1536
  static tabuleiro100 + #341, #1536
  static tabuleiro100 + #342, #1536
  static tabuleiro100 + #343, #1536
  static tabuleiro100 + #344, #1536
  static tabuleiro100 + #345, #1536
  static tabuleiro100 + #346, #1536
  static tabuleiro100 + #347, #1536
  static tabuleiro100 + #348, #1536
  static tabuleiro100 + #349, #1536
  static tabuleiro100 + #350, #1280
  static tabuleiro100 + #351, #1280
  static tabuleiro100 + #352, #1536
  static tabuleiro100 + #353, #1536
  static tabuleiro100 + #354, #1536
  static tabuleiro100 + #355, #1536
  static tabuleiro100 + #356, #1536
  static tabuleiro100 + #357, #1536
  static tabuleiro100 + #358, #1536
  static tabuleiro100 + #359, #1536

  ;Linha 9
  static tabuleiro100 + #360, #1536
  static tabuleiro100 + #361, #1536
  static tabuleiro100 + #362, #1536
  static tabuleiro100 + #363, #768
  static tabuleiro100 + #364, #768
  static tabuleiro100 + #365, #768
  static tabuleiro100 + #366, #1536
  static tabuleiro100 + #367, #1536
  static tabuleiro100 + #368, #1280
  static tabuleiro100 + #369, #1280
  static tabuleiro100 + #370, #1536
  static tabuleiro100 + #371, #1536
  static tabuleiro100 + #372, #1536
  static tabuleiro100 + #373, #1536
  static tabuleiro100 + #374, #1536
  static tabuleiro100 + #375, #1536
  static tabuleiro100 + #376, #1536
  static tabuleiro100 + #377, #1536
  static tabuleiro100 + #378, #1536
  static tabuleiro100 + #379, #1536
  static tabuleiro100 + #380, #1536
  static tabuleiro100 + #381, #1536
  static tabuleiro100 + #382, #1536
  static tabuleiro100 + #383, #1536
  static tabuleiro100 + #384, #1536
  static tabuleiro100 + #385, #1536
  static tabuleiro100 + #386, #1536
  static tabuleiro100 + #387, #1536
  static tabuleiro100 + #388, #1536
  static tabuleiro100 + #389, #1536
  static tabuleiro100 + #390, #1280
  static tabuleiro100 + #391, #1280
  static tabuleiro100 + #392, #1536
  static tabuleiro100 + #393, #1536
  static tabuleiro100 + #394, #1536
  static tabuleiro100 + #395, #1536
  static tabuleiro100 + #396, #1536
  static tabuleiro100 + #397, #1536
  static tabuleiro100 + #398, #1536
  static tabuleiro100 + #399, #1536

  ;Linha 10
  static tabuleiro100 + #400, #1536
  static tabuleiro100 + #401, #1536
  static tabuleiro100 + #402, #1536
  static tabuleiro100 + #403, #768
  static tabuleiro100 + #404, #768
  static tabuleiro100 + #405, #768
  static tabuleiro100 + #406, #768
  static tabuleiro100 + #407, #1536
  static tabuleiro100 + #408, #1280
  static tabuleiro100 + #409, #1280
  static tabuleiro100 + #410, #1536
  static tabuleiro100 + #411, #1536
  static tabuleiro100 + #412, #1536
  static tabuleiro100 + #413, #1536
  static tabuleiro100 + #414, #1536
  static tabuleiro100 + #415, #1536
  static tabuleiro100 + #416, #1536
  static tabuleiro100 + #417, #1536
  static tabuleiro100 + #418, #1536
  static tabuleiro100 + #419, #1536
  static tabuleiro100 + #420, #1536
  static tabuleiro100 + #421, #1536
  static tabuleiro100 + #422, #1536
  static tabuleiro100 + #423, #1536
  static tabuleiro100 + #424, #1536
  static tabuleiro100 + #425, #1536
  static tabuleiro100 + #426, #1536
  static tabuleiro100 + #427, #1536
  static tabuleiro100 + #428, #1536
  static tabuleiro100 + #429, #1536
  static tabuleiro100 + #430, #1280
  static tabuleiro100 + #431, #1280
  static tabuleiro100 + #432, #1536
  static tabuleiro100 + #433, #1536
  static tabuleiro100 + #434, #1536
  static tabuleiro100 + #435, #1536
  static tabuleiro100 + #436, #1536
  static tabuleiro100 + #437, #1536
  static tabuleiro100 + #438, #1536
  static tabuleiro100 + #439, #1536

  ;Linha 11
  static tabuleiro100 + #440, #1536
  static tabuleiro100 + #441, #1536
  static tabuleiro100 + #442, #768
  static tabuleiro100 + #443, #768
  static tabuleiro100 + #444, #2048
  static tabuleiro100 + #445, #2048
  static tabuleiro100 + #446, #1536
  static tabuleiro100 + #447, #1536
  static tabuleiro100 + #448, #1280
  static tabuleiro100 + #449, #1280
  static tabuleiro100 + #450, #1536
  static tabuleiro100 + #451, #1536
  static tabuleiro100 + #452, #1536
  static tabuleiro100 + #453, #1536
  static tabuleiro100 + #454, #1536
  static tabuleiro100 + #455, #1536
  static tabuleiro100 + #456, #1536
  static tabuleiro100 + #457, #1536
  static tabuleiro100 + #458, #1536
  static tabuleiro100 + #459, #1536
  static tabuleiro100 + #460, #1536
  static tabuleiro100 + #461, #1536
  static tabuleiro100 + #462, #1536
  static tabuleiro100 + #463, #1536
  static tabuleiro100 + #464, #1536
  static tabuleiro100 + #465, #1536
  static tabuleiro100 + #466, #1536
  static tabuleiro100 + #467, #1536
  static tabuleiro100 + #468, #1536
  static tabuleiro100 + #469, #1536
  static tabuleiro100 + #470, #1280
  static tabuleiro100 + #471, #1280
  static tabuleiro100 + #472, #1536
  static tabuleiro100 + #473, #1536
  static tabuleiro100 + #474, #1536
  static tabuleiro100 + #475, #1536
  static tabuleiro100 + #476, #1536
  static tabuleiro100 + #477, #1536
  static tabuleiro100 + #478, #1536
  static tabuleiro100 + #479, #1536

  ;Linha 12
  static tabuleiro100 + #480, #1536
  static tabuleiro100 + #481, #1536
  static tabuleiro100 + #482, #1536
  static tabuleiro100 + #483, #1536
  static tabuleiro100 + #484, #2048
  static tabuleiro100 + #485, #1536
  static tabuleiro100 + #486, #1536
  static tabuleiro100 + #487, #1536
  static tabuleiro100 + #488, #1280
  static tabuleiro100 + #489, #1280
  static tabuleiro100 + #490, #1536
  static tabuleiro100 + #491, #1536
  static tabuleiro100 + #492, #1536
  static tabuleiro100 + #493, #1536
  static tabuleiro100 + #494, #1536
  static tabuleiro100 + #495, #1536
  static tabuleiro100 + #496, #1536
  static tabuleiro100 + #497, #1536
  static tabuleiro100 + #498, #1536
  static tabuleiro100 + #499, #1536
  static tabuleiro100 + #500, #1536
  static tabuleiro100 + #501, #1536
  static tabuleiro100 + #502, #1536
  static tabuleiro100 + #503, #1536
  static tabuleiro100 + #504, #1536
  static tabuleiro100 + #505, #1536
  static tabuleiro100 + #506, #1536
  static tabuleiro100 + #507, #1536
  static tabuleiro100 + #508, #1536
  static tabuleiro100 + #509, #1536
  static tabuleiro100 + #510, #1280
  static tabuleiro100 + #511, #1280
  static tabuleiro100 + #512, #1536
  static tabuleiro100 + #513, #1536
  static tabuleiro100 + #514, #1536
  static tabuleiro100 + #515, #1536
  static tabuleiro100 + #516, #1536
  static tabuleiro100 + #517, #1536
  static tabuleiro100 + #518, #1536
  static tabuleiro100 + #519, #1536

  ;Linha 13
  static tabuleiro100 + #520, #1536
  static tabuleiro100 + #521, #1536
  static tabuleiro100 + #522, #768
  static tabuleiro100 + #523, #768
  static tabuleiro100 + #524, #2048
  static tabuleiro100 + #525, #768
  static tabuleiro100 + #526, #1536
  static tabuleiro100 + #527, #1536
  static tabuleiro100 + #528, #1280
  static tabuleiro100 + #529, #1280
  static tabuleiro100 + #530, #1536
  static tabuleiro100 + #531, #1536
  static tabuleiro100 + #532, #1536
  static tabuleiro100 + #533, #1536
  static tabuleiro100 + #534, #1536
  static tabuleiro100 + #535, #1536
  static tabuleiro100 + #536, #1536
  static tabuleiro100 + #537, #1536
  static tabuleiro100 + #538, #1536
  static tabuleiro100 + #539, #1536
  static tabuleiro100 + #540, #1536
  static tabuleiro100 + #541, #1536
  static tabuleiro100 + #542, #1536
  static tabuleiro100 + #543, #1536
  static tabuleiro100 + #544, #1536
  static tabuleiro100 + #545, #1536
  static tabuleiro100 + #546, #1536
  static tabuleiro100 + #547, #1536
  static tabuleiro100 + #548, #1536
  static tabuleiro100 + #549, #1536
  static tabuleiro100 + #550, #1280
  static tabuleiro100 + #551, #1280
  static tabuleiro100 + #552, #1536
  static tabuleiro100 + #553, #1536
  static tabuleiro100 + #554, #1536
  static tabuleiro100 + #555, #1536
  static tabuleiro100 + #556, #1536
  static tabuleiro100 + #557, #1536
  static tabuleiro100 + #558, #1536
  static tabuleiro100 + #559, #1536

  ;Linha 14
  static tabuleiro100 + #560, #1536
  static tabuleiro100 + #561, #768
  static tabuleiro100 + #562, #768
  static tabuleiro100 + #563, #768
  static tabuleiro100 + #564, #768
  static tabuleiro100 + #565, #768
  static tabuleiro100 + #566, #1536
  static tabuleiro100 + #567, #1536
  static tabuleiro100 + #568, #1280
  static tabuleiro100 + #569, #1280
  static tabuleiro100 + #570, #1536
  static tabuleiro100 + #571, #1536
  static tabuleiro100 + #572, #1536
  static tabuleiro100 + #573, #1536
  static tabuleiro100 + #574, #1536
  static tabuleiro100 + #575, #1536
  static tabuleiro100 + #576, #1536
  static tabuleiro100 + #577, #1536
  static tabuleiro100 + #578, #1536
  static tabuleiro100 + #579, #1536
  static tabuleiro100 + #580, #1536
  static tabuleiro100 + #581, #1536
  static tabuleiro100 + #582, #1536
  static tabuleiro100 + #583, #1536
  static tabuleiro100 + #584, #1536
  static tabuleiro100 + #585, #1536
  static tabuleiro100 + #586, #1536
  static tabuleiro100 + #587, #1536
  static tabuleiro100 + #588, #1536
  static tabuleiro100 + #589, #1536
  static tabuleiro100 + #590, #1280
  static tabuleiro100 + #591, #1280
  static tabuleiro100 + #592, #1536
  static tabuleiro100 + #593, #1536
  static tabuleiro100 + #594, #1536
  static tabuleiro100 + #595, #1536
  static tabuleiro100 + #596, #1536
  static tabuleiro100 + #597, #1536
  static tabuleiro100 + #598, #1536
  static tabuleiro100 + #599, #1536

  ;Linha 15
  static tabuleiro100 + #600, #768
  static tabuleiro100 + #601, #768
  static tabuleiro100 + #602, #768
  static tabuleiro100 + #603, #768
  static tabuleiro100 + #604, #768
  static tabuleiro100 + #605, #768
  static tabuleiro100 + #606, #768
  static tabuleiro100 + #607, #768
  static tabuleiro100 + #608, #1280
  static tabuleiro100 + #609, #1280
  static tabuleiro100 + #610, #1536
  static tabuleiro100 + #611, #1536
  static tabuleiro100 + #612, #1536
  static tabuleiro100 + #613, #1536
  static tabuleiro100 + #614, #1536
  static tabuleiro100 + #615, #1536
  static tabuleiro100 + #616, #1536
  static tabuleiro100 + #617, #1536
  static tabuleiro100 + #618, #1536
  static tabuleiro100 + #619, #1536
  static tabuleiro100 + #620, #1536
  static tabuleiro100 + #621, #1536
  static tabuleiro100 + #622, #1536
  static tabuleiro100 + #623, #1536
  static tabuleiro100 + #624, #1536
  static tabuleiro100 + #625, #1536
  static tabuleiro100 + #626, #1536
  static tabuleiro100 + #627, #1536
  static tabuleiro100 + #628, #1536
  static tabuleiro100 + #629, #1536
  static tabuleiro100 + #630, #1280
  static tabuleiro100 + #631, #1280
  static tabuleiro100 + #632, #1536
  static tabuleiro100 + #633, #1536
  static tabuleiro100 + #634, #1536
  static tabuleiro100 + #635, #1536
  static tabuleiro100 + #636, #1536
  static tabuleiro100 + #637, #1536
  static tabuleiro100 + #638, #1536
  static tabuleiro100 + #639, #1536

  ;Linha 16
  static tabuleiro100 + #640, #768
  static tabuleiro100 + #641, #1536
  static tabuleiro100 + #642, #768
  static tabuleiro100 + #643, #768
  static tabuleiro100 + #644, #768
  static tabuleiro100 + #645, #768
  static tabuleiro100 + #646, #1536
  static tabuleiro100 + #647, #1536
  static tabuleiro100 + #648, #1280
  static tabuleiro100 + #649, #1280
  static tabuleiro100 + #650, #1536
  static tabuleiro100 + #651, #1536
  static tabuleiro100 + #652, #1536
  static tabuleiro100 + #653, #1536
  static tabuleiro100 + #654, #1536
  static tabuleiro100 + #655, #1536
  static tabuleiro100 + #656, #1536
  static tabuleiro100 + #657, #1536
  static tabuleiro100 + #658, #1536
  static tabuleiro100 + #659, #1536
  static tabuleiro100 + #660, #1536
  static tabuleiro100 + #661, #1536
  static tabuleiro100 + #662, #1536
  static tabuleiro100 + #663, #1536
  static tabuleiro100 + #664, #1536
  static tabuleiro100 + #665, #1536
  static tabuleiro100 + #666, #1536
  static tabuleiro100 + #667, #1536
  static tabuleiro100 + #668, #1536
  static tabuleiro100 + #669, #1536
  static tabuleiro100 + #670, #1280
  static tabuleiro100 + #671, #1280
  static tabuleiro100 + #672, #1536
  static tabuleiro100 + #673, #1536
  static tabuleiro100 + #674, #1536
  static tabuleiro100 + #675, #1536
  static tabuleiro100 + #676, #1536
  static tabuleiro100 + #677, #1536
  static tabuleiro100 + #678, #1536
  static tabuleiro100 + #679, #1536

  ;Linha 17
  static tabuleiro100 + #680, #2048
  static tabuleiro100 + #681, #1536
  static tabuleiro100 + #682, #768
  static tabuleiro100 + #683, #768
  static tabuleiro100 + #684, #768
  static tabuleiro100 + #685, #768
  static tabuleiro100 + #686, #768
  static tabuleiro100 + #687, #1536
  static tabuleiro100 + #688, #1280
  static tabuleiro100 + #689, #1280
  static tabuleiro100 + #690, #1536
  static tabuleiro100 + #691, #1536
  static tabuleiro100 + #692, #1536
  static tabuleiro100 + #693, #1536
  static tabuleiro100 + #694, #1536
  static tabuleiro100 + #695, #1536
  static tabuleiro100 + #696, #1536
  static tabuleiro100 + #697, #1536
  static tabuleiro100 + #698, #1536
  static tabuleiro100 + #699, #1536
  static tabuleiro100 + #700, #1536
  static tabuleiro100 + #701, #1536
  static tabuleiro100 + #702, #1536
  static tabuleiro100 + #703, #1536
  static tabuleiro100 + #704, #1536
  static tabuleiro100 + #705, #1536
  static tabuleiro100 + #706, #1536
  static tabuleiro100 + #707, #1536
  static tabuleiro100 + #708, #1536
  static tabuleiro100 + #709, #1536
  static tabuleiro100 + #710, #1280
  static tabuleiro100 + #711, #1280
  static tabuleiro100 + #712, #1536
  static tabuleiro100 + #713, #1536
  static tabuleiro100 + #714, #1536
  static tabuleiro100 + #715, #1536
  static tabuleiro100 + #716, #1536
  static tabuleiro100 + #717, #1536
  static tabuleiro100 + #718, #1536
  static tabuleiro100 + #719, #1536

  ;Linha 18
  static tabuleiro100 + #720, #1536
  static tabuleiro100 + #721, #1536
  static tabuleiro100 + #722, #768
  static tabuleiro100 + #723, #1536
  static tabuleiro100 + #724, #1536
  static tabuleiro100 + #725, #1536
  static tabuleiro100 + #726, #768
  static tabuleiro100 + #727, #1536
  static tabuleiro100 + #728, #1280
  static tabuleiro100 + #729, #1280
  static tabuleiro100 + #730, #1536
  static tabuleiro100 + #731, #1536
  static tabuleiro100 + #732, #1536
  static tabuleiro100 + #733, #1536
  static tabuleiro100 + #734, #1536
  static tabuleiro100 + #735, #1536
  static tabuleiro100 + #736, #1536
  static tabuleiro100 + #737, #1536
  static tabuleiro100 + #738, #1536
  static tabuleiro100 + #739, #1536
  static tabuleiro100 + #740, #1536
  static tabuleiro100 + #741, #1536
  static tabuleiro100 + #742, #1536
  static tabuleiro100 + #743, #1536
  static tabuleiro100 + #744, #1536
  static tabuleiro100 + #745, #1536
  static tabuleiro100 + #746, #1536
  static tabuleiro100 + #747, #1536
  static tabuleiro100 + #748, #1536
  static tabuleiro100 + #749, #1536
  static tabuleiro100 + #750, #1280
  static tabuleiro100 + #751, #1280
  static tabuleiro100 + #752, #1536
  static tabuleiro100 + #753, #1536
  static tabuleiro100 + #754, #1536
  static tabuleiro100 + #755, #1536
  static tabuleiro100 + #756, #1536
  static tabuleiro100 + #757, #1536
  static tabuleiro100 + #758, #1536
  static tabuleiro100 + #759, #1536

  ;Linha 19
  static tabuleiro100 + #760, #1536
  static tabuleiro100 + #761, #1536
  static tabuleiro100 + #762, #768
  static tabuleiro100 + #763, #1536
  static tabuleiro100 + #764, #1536
  static tabuleiro100 + #765, #1536
  static tabuleiro100 + #766, #768
  static tabuleiro100 + #767, #1536
  static tabuleiro100 + #768, #1280
  static tabuleiro100 + #769, #1280
  static tabuleiro100 + #770, #1536
  static tabuleiro100 + #771, #1536
  static tabuleiro100 + #772, #1536
  static tabuleiro100 + #773, #1536
  static tabuleiro100 + #774, #1536
  static tabuleiro100 + #775, #1536
  static tabuleiro100 + #776, #1536
  static tabuleiro100 + #777, #1536
  static tabuleiro100 + #778, #1536
  static tabuleiro100 + #779, #1536
  static tabuleiro100 + #780, #1536
  static tabuleiro100 + #781, #1536
  static tabuleiro100 + #782, #1536
  static tabuleiro100 + #783, #1536
  static tabuleiro100 + #784, #1536
  static tabuleiro100 + #785, #1536
  static tabuleiro100 + #786, #1536
  static tabuleiro100 + #787, #1536
  static tabuleiro100 + #788, #1536
  static tabuleiro100 + #789, #1536
  static tabuleiro100 + #790, #1280
  static tabuleiro100 + #791, #1280
  static tabuleiro100 + #792, #1536
  static tabuleiro100 + #793, #1536
  static tabuleiro100 + #794, #1536
  static tabuleiro100 + #795, #1536
  static tabuleiro100 + #796, #1536
  static tabuleiro100 + #797, #1536
  static tabuleiro100 + #798, #1536
  static tabuleiro100 + #799, #1536

  ;Linha 20
  static tabuleiro100 + #800, #1536
  static tabuleiro100 + #801, #1536
  static tabuleiro100 + #802, #768
  static tabuleiro100 + #803, #768
  static tabuleiro100 + #804, #1536
  static tabuleiro100 + #805, #1536
  static tabuleiro100 + #806, #768
  static tabuleiro100 + #807, #768
  static tabuleiro100 + #808, #1280
  static tabuleiro100 + #809, #1280
  static tabuleiro100 + #810, #1536
  static tabuleiro100 + #811, #1536
  static tabuleiro100 + #812, #1536
  static tabuleiro100 + #813, #1536
  static tabuleiro100 + #814, #1536
  static tabuleiro100 + #815, #1536
  static tabuleiro100 + #816, #1536
  static tabuleiro100 + #817, #1536
  static tabuleiro100 + #818, #1536
  static tabuleiro100 + #819, #1536
  static tabuleiro100 + #820, #1536
  static tabuleiro100 + #821, #1536
  static tabuleiro100 + #822, #1536
  static tabuleiro100 + #823, #1536
  static tabuleiro100 + #824, #1536
  static tabuleiro100 + #825, #1536
  static tabuleiro100 + #826, #1536
  static tabuleiro100 + #827, #1536
  static tabuleiro100 + #828, #1536
  static tabuleiro100 + #829, #1536
  static tabuleiro100 + #830, #1280
  static tabuleiro100 + #831, #1280
  static tabuleiro100 + #832, #1536
  static tabuleiro100 + #833, #1536
  static tabuleiro100 + #834, #1536
  static tabuleiro100 + #835, #1536
  static tabuleiro100 + #836, #1536
  static tabuleiro100 + #837, #1536
  static tabuleiro100 + #838, #1536
  static tabuleiro100 + #839, #1536

  ;Linha 21
  static tabuleiro100 + #840, #2560
  static tabuleiro100 + #841, #2560
  static tabuleiro100 + #842, #2560
  static tabuleiro100 + #843, #2560
  static tabuleiro100 + #844, #2560
  static tabuleiro100 + #845, #2560
  static tabuleiro100 + #846, #2560
  static tabuleiro100 + #847, #2560
  static tabuleiro100 + #848, #1280
  static tabuleiro100 + #849, #1280
  static tabuleiro100 + #850, #2560
  static tabuleiro100 + #851, #2560
  static tabuleiro100 + #852, #2305
  static tabuleiro100 + #853, #2560
  static tabuleiro100 + #854, #2305
  static tabuleiro100 + #855, #2560
  static tabuleiro100 + #856, #2560
  static tabuleiro100 + #857, #2560
  static tabuleiro100 + #858, #2560
  static tabuleiro100 + #859, #2560
  static tabuleiro100 + #860, #2560
  static tabuleiro100 + #861, #2305
  static tabuleiro100 + #862, #2560
  static tabuleiro100 + #863, #2305
  static tabuleiro100 + #864, #2560
  static tabuleiro100 + #865, #2560
  static tabuleiro100 + #866, #2560
  static tabuleiro100 + #867, #2560
  static tabuleiro100 + #868, #2560
  static tabuleiro100 + #869, #2305
  static tabuleiro100 + #870, #1280
  static tabuleiro100 + #871, #1280
  static tabuleiro100 + #872, #2560
  static tabuleiro100 + #873, #2560
  static tabuleiro100 + #874, #2305
  static tabuleiro100 + #875, #2560
  static tabuleiro100 + #876, #2560
  static tabuleiro100 + #877, #2305
  static tabuleiro100 + #878, #2560
  static tabuleiro100 + #879, #2560

  ;Linha 22
  static tabuleiro100 + #880, #2560
  static tabuleiro100 + #881, #2560
  static tabuleiro100 + #882, #256
  static tabuleiro100 + #883, #256
  static tabuleiro100 + #884, #2560
  static tabuleiro100 + #885, #256
  static tabuleiro100 + #886, #2560
  static tabuleiro100 + #887, #256
  static tabuleiro100 + #888, #2560
  static tabuleiro100 + #889, #1280
  static tabuleiro100 + #890, #1280
  static tabuleiro100 + #891, #1280
  static tabuleiro100 + #892, #1280
  static tabuleiro100 + #893, #1280
  static tabuleiro100 + #894, #1280
  static tabuleiro100 + #895, #1280
  static tabuleiro100 + #896, #1280
  static tabuleiro100 + #897, #1280
  static tabuleiro100 + #898, #1280
  static tabuleiro100 + #899, #1280
  static tabuleiro100 + #900, #1280
  static tabuleiro100 + #901, #1280
  static tabuleiro100 + #902, #1280
  static tabuleiro100 + #903, #1280
  static tabuleiro100 + #904, #1280
  static tabuleiro100 + #905, #1280
  static tabuleiro100 + #906, #1280
  static tabuleiro100 + #907, #1280
  static tabuleiro100 + #908, #1280
  static tabuleiro100 + #909, #1280
  static tabuleiro100 + #910, #1280
  static tabuleiro100 + #911, #2560
  static tabuleiro100 + #912, #256
  static tabuleiro100 + #913, #2560
  static tabuleiro100 + #914, #256
  static tabuleiro100 + #915, #2560
  static tabuleiro100 + #916, #2560
  static tabuleiro100 + #917, #256
  static tabuleiro100 + #918, #2560
  static tabuleiro100 + #919, #256

  ;Linha 23
  static tabuleiro100 + #920, #256
  static tabuleiro100 + #921, #256
  static tabuleiro100 + #922, #256
  static tabuleiro100 + #923, #2560
  static tabuleiro100 + #924, #256
  static tabuleiro100 + #925, #256
  static tabuleiro100 + #926, #256
  static tabuleiro100 + #927, #256
  static tabuleiro100 + #928, #2560
  static tabuleiro100 + #929, #256
  static tabuleiro100 + #930, #1280
  static tabuleiro100 + #931, #1280
  static tabuleiro100 + #932, #1280
  static tabuleiro100 + #933, #1280
  static tabuleiro100 + #934, #1280
  static tabuleiro100 + #935, #1280
  static tabuleiro100 + #936, #1280
  static tabuleiro100 + #937, #1280
  static tabuleiro100 + #938, #1280
  static tabuleiro100 + #939, #1280
  static tabuleiro100 + #940, #1280
  static tabuleiro100 + #941, #1280
  static tabuleiro100 + #942, #1280
  static tabuleiro100 + #943, #1280
  static tabuleiro100 + #944, #1280
  static tabuleiro100 + #945, #1280
  static tabuleiro100 + #946, #1280
  static tabuleiro100 + #947, #1280
  static tabuleiro100 + #948, #1280
  static tabuleiro100 + #949, #1280
  static tabuleiro100 + #950, #256
  static tabuleiro100 + #951, #256
  static tabuleiro100 + #952, #256
  static tabuleiro100 + #953, #256
  static tabuleiro100 + #954, #2560
  static tabuleiro100 + #955, #256
  static tabuleiro100 + #956, #256
  static tabuleiro100 + #957, #256
  static tabuleiro100 + #958, #256
  static tabuleiro100 + #959, #2560

  ;Linha 24
  static tabuleiro100 + #960, #256
  static tabuleiro100 + #961, #256
  static tabuleiro100 + #962, #256
  static tabuleiro100 + #963, #256
  static tabuleiro100 + #964, #256
  static tabuleiro100 + #965, #256
  static tabuleiro100 + #966, #256
  static tabuleiro100 + #967, #256
  static tabuleiro100 + #968, #256
  static tabuleiro100 + #969, #256
  static tabuleiro100 + #970, #256
  static tabuleiro100 + #971, #256
  static tabuleiro100 + #972, #256
  static tabuleiro100 + #973, #256
  static tabuleiro100 + #974, #256
  static tabuleiro100 + #975, #256
  static tabuleiro100 + #976, #256
  static tabuleiro100 + #977, #256
  static tabuleiro100 + #978, #256
  static tabuleiro100 + #979, #256
  static tabuleiro100 + #980, #256
  static tabuleiro100 + #981, #256
  static tabuleiro100 + #982, #256
  static tabuleiro100 + #983, #256
  static tabuleiro100 + #984, #256
  static tabuleiro100 + #985, #256
  static tabuleiro100 + #986, #256
  static tabuleiro100 + #987, #256
  static tabuleiro100 + #988, #256
  static tabuleiro100 + #989, #256
  static tabuleiro100 + #990, #256
  static tabuleiro100 + #991, #256
  static tabuleiro100 + #992, #256
  static tabuleiro100 + #993, #256
  static tabuleiro100 + #994, #256
  static tabuleiro100 + #995, #256
  static tabuleiro100 + #996, #256
  static tabuleiro100 + #997, #256
  static tabuleiro100 + #998, #256
  static tabuleiro100 + #999, #256

  ;Linha 25
  static tabuleiro100 + #1000, #256
  static tabuleiro100 + #1001, #256
  static tabuleiro100 + #1002, #256
  static tabuleiro100 + #1003, #256
  static tabuleiro100 + #1004, #256
  static tabuleiro100 + #1005, #256
  static tabuleiro100 + #1006, #256
  static tabuleiro100 + #1007, #256
  static tabuleiro100 + #1008, #256
  static tabuleiro100 + #1009, #256
  static tabuleiro100 + #1010, #256
  static tabuleiro100 + #1011, #256
  static tabuleiro100 + #1012, #256
  static tabuleiro100 + #1013, #256
  static tabuleiro100 + #1014, #256
  static tabuleiro100 + #1015, #256
  static tabuleiro100 + #1016, #256
  static tabuleiro100 + #1017, #256
  static tabuleiro100 + #1018, #256
  static tabuleiro100 + #1019, #256
  static tabuleiro100 + #1020, #256
  static tabuleiro100 + #1021, #256
  static tabuleiro100 + #1022, #256
  static tabuleiro100 + #1023, #256
  static tabuleiro100 + #1024, #256
  static tabuleiro100 + #1025, #256
  static tabuleiro100 + #1026, #256
  static tabuleiro100 + #1027, #256
  static tabuleiro100 + #1028, #256
  static tabuleiro100 + #1029, #256
  static tabuleiro100 + #1030, #256
  static tabuleiro100 + #1031, #256
  static tabuleiro100 + #1032, #256
  static tabuleiro100 + #1033, #256
  static tabuleiro100 + #1034, #256
  static tabuleiro100 + #1035, #256
  static tabuleiro100 + #1036, #256
  static tabuleiro100 + #1037, #256
  static tabuleiro100 + #1038, #256
  static tabuleiro100 + #1039, #256

  ;Linha 26
  static tabuleiro100 + #1040, #256
  static tabuleiro100 + #1041, #256
  static tabuleiro100 + #1042, #256
  static tabuleiro100 + #1043, #256
  static tabuleiro100 + #1044, #256
  static tabuleiro100 + #1045, #256
  static tabuleiro100 + #1046, #256
  static tabuleiro100 + #1047, #256
  static tabuleiro100 + #1048, #256
  static tabuleiro100 + #1049, #256
  static tabuleiro100 + #1050, #256
  static tabuleiro100 + #1051, #256
  static tabuleiro100 + #1052, #256
  static tabuleiro100 + #1053, #256
  static tabuleiro100 + #1054, #256
  static tabuleiro100 + #1055, #256
  static tabuleiro100 + #1056, #256
  static tabuleiro100 + #1057, #256
  static tabuleiro100 + #1058, #256
  static tabuleiro100 + #1059, #256
  static tabuleiro100 + #1060, #256
  static tabuleiro100 + #1061, #256
  static tabuleiro100 + #1062, #256
  static tabuleiro100 + #1063, #256
  static tabuleiro100 + #1064, #256
  static tabuleiro100 + #1065, #256
  static tabuleiro100 + #1066, #256
  static tabuleiro100 + #1067, #256
  static tabuleiro100 + #1068, #256
  static tabuleiro100 + #1069, #256
  static tabuleiro100 + #1070, #256
  static tabuleiro100 + #1071, #256
  static tabuleiro100 + #1072, #256
  static tabuleiro100 + #1073, #256
  static tabuleiro100 + #1074, #256
  static tabuleiro100 + #1075, #256
  static tabuleiro100 + #1076, #256
  static tabuleiro100 + #1077, #256
  static tabuleiro100 + #1078, #256
  static tabuleiro100 + #1079, #256

  ;Linha 27
  static tabuleiro100 + #1080, #256
  static tabuleiro100 + #1081, #256
  static tabuleiro100 + #1082, #256
  static tabuleiro100 + #1083, #256
  static tabuleiro100 + #1084, #256
  static tabuleiro100 + #1085, #256
  static tabuleiro100 + #1086, #256
  static tabuleiro100 + #1087, #256
  static tabuleiro100 + #1088, #256
  static tabuleiro100 + #1089, #256
  static tabuleiro100 + #1090, #256
  static tabuleiro100 + #1091, #256
  static tabuleiro100 + #1092, #256
  static tabuleiro100 + #1093, #256
  static tabuleiro100 + #1094, #256
  static tabuleiro100 + #1095, #256
  static tabuleiro100 + #1096, #256
  static tabuleiro100 + #1097, #256
  static tabuleiro100 + #1098, #256
  static tabuleiro100 + #1099, #256
  static tabuleiro100 + #1100, #256
  static tabuleiro100 + #1101, #256
  static tabuleiro100 + #1102, #256
  static tabuleiro100 + #1103, #256
  static tabuleiro100 + #1104, #256
  static tabuleiro100 + #1105, #256
  static tabuleiro100 + #1106, #256
  static tabuleiro100 + #1107, #256
  static tabuleiro100 + #1108, #256
  static tabuleiro100 + #1109, #256
  static tabuleiro100 + #1110, #256
  static tabuleiro100 + #1111, #256
  static tabuleiro100 + #1112, #256
  static tabuleiro100 + #1113, #256
  static tabuleiro100 + #1114, #256
  static tabuleiro100 + #1115, #256
  static tabuleiro100 + #1116, #256
  static tabuleiro100 + #1117, #256
  static tabuleiro100 + #1118, #256
  static tabuleiro100 + #1119, #256

  ;Linha 28
  static tabuleiro100 + #1120, #256
  static tabuleiro100 + #1121, #256
  static tabuleiro100 + #1122, #256
  static tabuleiro100 + #1123, #256
  static tabuleiro100 + #1124, #256
  static tabuleiro100 + #1125, #256
  static tabuleiro100 + #1126, #256
  static tabuleiro100 + #1127, #256
  static tabuleiro100 + #1128, #256
  static tabuleiro100 + #1129, #256
  static tabuleiro100 + #1130, #256
  static tabuleiro100 + #1131, #256
  static tabuleiro100 + #1132, #256
  static tabuleiro100 + #1133, #256
  static tabuleiro100 + #1134, #256
  static tabuleiro100 + #1135, #256
  static tabuleiro100 + #1136, #256
  static tabuleiro100 + #1137, #256
  static tabuleiro100 + #1138, #256
  static tabuleiro100 + #1139, #256
  static tabuleiro100 + #1140, #256
  static tabuleiro100 + #1141, #256
  static tabuleiro100 + #1142, #256
  static tabuleiro100 + #1143, #256
  static tabuleiro100 + #1144, #256
  static tabuleiro100 + #1145, #256
  static tabuleiro100 + #1146, #256
  static tabuleiro100 + #1147, #256
  static tabuleiro100 + #1148, #256
  static tabuleiro100 + #1149, #256
  static tabuleiro100 + #1150, #256
  static tabuleiro100 + #1151, #256
  static tabuleiro100 + #1152, #256
  static tabuleiro100 + #1153, #256
  static tabuleiro100 + #1154, #256
  static tabuleiro100 + #1155, #256
  static tabuleiro100 + #1156, #256
  static tabuleiro100 + #1157, #256
  static tabuleiro100 + #1158, #256
  static tabuleiro100 + #1159, #256

  ;Linha 29
  static tabuleiro100 + #1160, #256
  static tabuleiro100 + #1161, #256
  static tabuleiro100 + #1162, #256
  static tabuleiro100 + #1163, #256
  static tabuleiro100 + #1164, #256
  static tabuleiro100 + #1165, #256
  static tabuleiro100 + #1166, #256
  static tabuleiro100 + #1167, #256
  static tabuleiro100 + #1168, #256
  static tabuleiro100 + #1169, #256
  static tabuleiro100 + #1170, #256
  static tabuleiro100 + #1171, #256
  static tabuleiro100 + #1172, #256
  static tabuleiro100 + #1173, #256
  static tabuleiro100 + #1174, #256
  static tabuleiro100 + #1175, #256
  static tabuleiro100 + #1176, #256
  static tabuleiro100 + #1177, #256
  static tabuleiro100 + #1178, #256
  static tabuleiro100 + #1179, #256
  static tabuleiro100 + #1180, #256
  static tabuleiro100 + #1181, #256
  static tabuleiro100 + #1182, #256
  static tabuleiro100 + #1183, #256
  static tabuleiro100 + #1184, #256
  static tabuleiro100 + #1185, #256
  static tabuleiro100 + #1186, #256
  static tabuleiro100 + #1187, #256
  static tabuleiro100 + #1188, #256
  static tabuleiro100 + #1189, #256
  static tabuleiro100 + #1190, #256
  static tabuleiro100 + #1191, #256
  static tabuleiro100 + #1192, #256
  static tabuleiro100 + #1193, #256
  static tabuleiro100 + #1194, #256
  static tabuleiro100 + #1195, #256
  static tabuleiro100 + #1196, #256
  static tabuleiro100 + #1197, #256
  static tabuleiro100 + #1198, #256
  static tabuleiro100 + #1199, #256

printtabuleiro100Screen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #tabuleiro100
  loadn R1, #0
  loadn R2, #1200

  printtabuleiro100ScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printtabuleiro100ScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts