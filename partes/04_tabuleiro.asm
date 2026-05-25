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
