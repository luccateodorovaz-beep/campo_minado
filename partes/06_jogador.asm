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
rts