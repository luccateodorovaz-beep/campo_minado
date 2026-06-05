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
    ; O QUE FAZER:
    ; 1. Fazer um loop de 0 a 99 (passando por todo o Tabuleiro).
    ; 2. Se a posicao atual tiver bomba, pula pra proxima.
    ; 3. Se nao tiver, checa os 8 vizinhos (cima, baixo, lados e diagonais).
    ; 4. Conta quantas bombas tem ao redor e guarda esse numero nos Bits 3 a 6.
    ; DICA: Cuidado com as bordas (ex: a posicao 9 nao tem vizinho na direita).
    rts

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
