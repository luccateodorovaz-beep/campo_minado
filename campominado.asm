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
MsgComandos: string "Comandos:    Andar - WASD | Revelar - ESPAÇO | Colocar/tirar bandeira - F"
MsgDerrota: string "B O O M!! Você pisou em uma mina."
MsgVitoria: string "PARABENS! Você venceu!"


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

; ===================================================================
; CalculaDicas: Conta as bombas vizinhas de cada celula vazia
; Sugestao de responsavel: Lucca
; ===================================================================
CalculaDicas:
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


; ===================================================================
; ImprimeTabuleiro: Desenha o grid 10x10 na tela
; Sugestao de responsavel: Covisi
; ===================================================================
;ImprimeTabuleiro:
    ; O QUE FAZER:
    ; 1. Fazer um loop de 0 a 99 lendo o vetor Tabuleiro.
    ; 2. Mapear o indice (0 a 99) para uma coordenada na tela (ex: centro da tela).
    ; 3. Checar os bits de cada posicao:
    ;    - Se Bit 1 (Revelado) == 0 e Bit 2 (Bandeira) == 0 -> Imprime '[ ]'
    ;    - Se Bit 1 (Revelado) == 0 e Bit 2 (Bandeira) == 1 -> Imprime '[F]'
    ;    - Se Bit 1 (Revelado) == 1 e Bit 0 (Bomba) == 1 -> Imprime ' * '
    ;    - Se Bit 1 (Revelado) == 1 e nao tem bomba -> Imprime o numero de vizinhos
 ;   rts

; ===================================================================
; DesenhaCursor: Destaca a posicao atual do jogador na tela
; Sugestao de responsavel: Lucca
; ===================================================================
DesenhaCursor:
    ; O QUE FAZER:
    ; 1. Ler a variavel 'PosCursor'.
    ; 2. Calcular onde isso fica na tela (mesma matematica do ImprimeTabuleiro).
    ; 3. Mudar a cor do caractere ou desenhar um cursor visual (ex: '< >' em volta).
    rts

; ===================================================================
; LeTeclado: Captura a tecla pressionada sem travar o jogo
; Sugestao de responsavel: Covisi
; ===================================================================
LeTeclado:
    ; O QUE FAZER:
    ; 1. Usar a instrucao 'inchar'.
    ; 2. Se retornar 255, significa que nada foi apertado -> Grava 255 em 'Letra' e sai.
    ; 3. Se retornar outra coisa, grava o valor na variavel global 'Letra'.
    rts

; ===================================================================
; MoveCursor: Atualiza a posicao do cursor usando WASD
; Sugestao de responsavel: Lucca
; ===================================================================
MoveCursor:
    ; O QUE FAZER:
    ; 1. Ler a variavel 'Letra'.
    ; 2. Comparar com 'w', 'a', 's', 'd'.
    ; 3. Se for 'w' (cima), subtrai 10 do 'PosCursor'.
    ; 4. Se for 's' (baixo), soma 10 no 'PosCursor'.
    ; 5. Se for 'a' (esquerda), subtrai 1. (Cuidado: usar MOD 10 pra nao vazar a linha).
    ; 6. Se for 'd' (direita), soma 1. (Cuidado: usar MOD 10 pra nao vazar a linha).
    ; 7. Atualizar 'PosAntCursor' com o valor antigo antes de mudar.
    rts

; ===================================================================
; AcaoJogador: Processa a abertura de casas ou colocacao de bandeiras
; Sugestao de responsavel: Covisi
; ===================================================================
AcaoJogador:
    ; O QUE FAZER:
    ; 1. Ler a variavel 'Letra'.
    ; 2. Se for a tecla 'f': Vai na posicao atual no Tabuleiro e inverte o Bit 2 (Bandeira).
    ; 3. Se for ' ' (Espaco): Vai na posicao atual no Tabuleiro.
    ;    - Liga o Bit 1 (Revelado).
    ;    - Checa o Bit 0 (Bomba). Se tiver bomba, seta GameOver = 1 (Perdeu).
    ;    - Se revelar a ultima casa vazia do mapa, seta GameOver = 2 (Venceu).
    rts

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
; ImprimeTabuleiro (VERSAO DEBUG TEMPORARIA)
; ===================================================================
ImprimeTabuleiro:
    push r0     ; contador do loop (0 a 99) / posicao na tela
    push r1     ; limite do loop (100)
    push r2     ; endereco base do Tabuleiro
    push r3     ; auxiliar para ler memoria e imprimir
    push r4     ; mascara do bit 0 (00000001)

    loadn r0, #0
    loadn r1, #100
    loadn r2, #Tabuleiro
    loadn r4, #1

ImprimeTabuleiro_DebugLoop:
    cmp r0, r1
    jeq ImprimeTabuleiro_Fim    ; se r0 == 100, acaba

    ; Le o valor no Tabuleiro
    add r3, r2, r0              ; r3 = Tabuleiro + i
    loadi r3, r3                ; r3 = Valor da memoria
    and r3, r3, r4              ; Isola o Bit 0 (Bomba)

    ; Checa se tem bomba (resultado do AND for 1)
    loadn r5, #0
    cmp r3, r5
    jeq ImprimeTabuleiro_Vazio

ImprimeTabuleiro_Bomba:
    loadn r3, #'*'              ; Carrega o asterisco
    outchar r3, r0              ; Imprime na tela na posicao r0
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Vazio:
    loadn r3, #'_'              ; Carrega underline
    outchar r3, r0              ; Imprime na tela na posicao r0

ImprimeTabuleiro_Prox:
    inc r0
    jmp ImprimeTabuleiro_DebugLoop

ImprimeTabuleiro_Fim:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
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