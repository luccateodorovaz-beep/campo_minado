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
loadn r0,#'f' ;Tecla f em r0 ( adiciona flag )
loadn r1,#' ' ; Tecla espaço em r1 ( revela posição atual )
LoopAcaoJogador:
    ;Ver qual tecla é
    load r3,Letra ;Le tecla atual
    cmp r0,r3 ;Ve se input é f e se for faz açaõ necessária
    jeq AcaoF
    cmp r3,r1 ;Ve se input é espaço e se for faz ação necessária
    jeq AcaoEspaco
    jne FinalAcaoJogador ; Se não for nem f nem espaço volta para o loop principal
    ;Primeiro função do F
    AcaoF:
        load r0, PosCursor ;Ve posição do cursor em relação ao inicio do vetor ( ver depois se está sendo utilizado )
        loadn r1,#Tabuleiro
        add r1,r1,r0 ;Ve posição atual do vetor que jogador se encontra 
        loadi r4,r1 ;Carrega o valor do endereço de r1 no r4 ( r1 é o valor do vetor na posiçaõ atual)
        loadn r2,#4  ;So o segundo bit ligado // 00000100
        xor r3,r2,r4 ;Agora basta fazer o xor com 4 porque se bit 2 for 0 vira 1 e se for 1 vira 0
        storei r1,r3 ;Carrega o valor atualizado no endereço de r1
        jmp FinalAcaoJogador

    AcaoEspaco:
        load r0, PosCursor ;Ve posição do cursor em relação ao inicio do vetor ( ver depois se está sendo utilizado )
        loadn r1,#Tabuleiro
        add r1,r1,r0 ;Ve posição atual do vetor que jogador se encontra 
        loadi r4,r1 ;Carrega valor do endereço r1 em r4
        LigaBit1:
            loadn r2,#2 
            or r3,r4,r2 ;Faz o or entre 2 (10) e o numero atual para ligar o bit( para ligar o bit 1 / se for 0 vira 1 e se for 1 continua 1)
            storei r1,r3;Carrega o valor de r3 no endereço de r1 ( atualizou mas com o bit0 ligado)
            LigaBit1Adjacente:
            ;; Falta fazer parte que abre casas adjacentes sem bomba e decrementa Casas Seguras quaando isso ocorre 

        ChecaBit0:
            loadn r2,#1 ;Para comprar o ultimo bit apenas
            and r3,r2,r3 ;Faz o and de um como o valor atualizado ( podia ser o valor não atualizado ) e guarda em r3
            jnz SetGameOverLose ;Se não for zero tem bomba logo acabou o jogo
            
            ;Se ficou é porque o jogo continua, agora tenho que ver se ele abriu a útlima casa vazia do mapa 
            SetGameOverWin:
            load r1, CasasSeguras 
            loadn r2,#0
            cmp r1,r2 ;Ve se o numero de casas seguras chegou a zero 
            jne FinalAcaoJogador ;Se nao chegou, continua com o loop de main ( sai de acao jogador )
            ;Se chegou ( não deu jump ) jogador venceu 
            loadn r2, #2
            store GameOver,r2
            jmp FinalAcaoJogador

            ;So vai chegar ate aqui se tiver achado bomba ao liberar
            SetGameOverLose:
            store GameOver, r2
            jmp  FinalAcaoJogador
    
        

    ; O QUE FAZER:
    ; 1. Ler a variavel 'Letra'.
    ; 2. Se for a tecla 'f': Vai na posicao atual no Tabuleiro e inverte o Bit 2 (Bandeira).
    ; 3. Se for ' ' (Espaco): Vai na posicao atual no Tabuleiro.
    ;    - Liga o Bit 1 (Revelado).
    ;    - Checa o Bit 0 (Bomba). Se tiver bomba, seta GameOver = 1 (Perdeu).
    ;    - Se revelar a ultima casa vazia do mapa, seta GameOver = 2 (Venceu).
FinalAcaoJogador:
pop r5
pop r4
pop r3
pop r2
pop r1
pop r0
rts
