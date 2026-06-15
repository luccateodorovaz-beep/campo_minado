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
    push r7
    
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
    
    ; check Revealed (bit 1)
    loadn r5, #2
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jne ImprimeTabuleiro_Revelado

ImprimeTabuleiro_NaoRevelado:
    ; check Bandeira (bit 2)
    loadn r5, #4
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jeq ImprimeTabuleiro_Vazio
    jmp ImprimeTabuleiro_Flag

ImprimeTabuleiro_Revelado:
    ; check Bomb (bit 0)
    loadn r5, #1
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jne ImprimeTabuleiro_Bomba

    ; mask hint (bits 3 to 6)
    loadn r5, #120      ; 1111000 in binary
    and r7, r4, r5
    
    loadn r5, #0
    cmp r7, r5
    jeq ImprimeTabuleiro_Zero
    
    loadn r5, #8
    cmp r7, r5
    jeq ImprimeTabuleiro_Um
    
    loadn r5, #16
    cmp r7, r5
    jeq ImprimeTabuleiro_Dois
    
    loadn r5, #24
    cmp r7, r5
    jeq ImprimeTabuleiro_Tres
    
    loadn r5, #32
    cmp r7, r5
    jeq ImprimeTabuleiro_Quatro
    
    loadn r5, #40
    cmp r7, r5
    jeq ImprimeTabuleiro_Cinco
    
    loadn r5, #48
    cmp r7, r5
    jeq ImprimeTabuleiro_Seis
    
    loadn r5, #56
    cmp r7, r5
    jeq ImprimeTabuleiro_Sete
    
    jmp ImprimeTabuleiro_Oito

ImprimeTabuleiro_Bomba:
    loadn r5, #103
    outchar r5, r3
    
    loadn r5, #102
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #100
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #101
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Zero:
    loadn r5, #3
    outchar r5, r3
    
    loadn r5, #3
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #3
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #3
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Um:
    loadn r5, #20
    outchar r5, r3
    
    loadn r5, #19
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #17
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #18
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Dois:
    loadn r5, #24
    outchar r5, r3
    
    loadn r5, #23
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #21
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #22
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Tres:
    loadn r5, #28
    outchar r5, r3
    
    loadn r5, #27
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #25
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #26
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Quatro:
    loadn r5, #33
    outchar r5, r3
    
    loadn r5, #59
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #29
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #30
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Cinco:
    loadn r5, #37
    outchar r5, r3
    
    loadn r5, #36
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #34
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #35
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Seis:
    loadn r5, #41
    outchar r5, r3
    
    loadn r5, #40
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #38
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #39
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Sete:
    loadn r5, #45
    outchar r5, r3
    
    loadn r5, #44
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #42
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #43
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Oito:
    loadn r5, #49
    outchar r5, r3
    
    loadn r5, #48
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #46
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #47
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

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
    loadn r7, #40
    add r6, r6, r7
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
    loadn r7, #40
    add r6, r6, r7
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
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
