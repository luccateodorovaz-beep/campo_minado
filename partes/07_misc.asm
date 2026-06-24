; ===================================================================
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

; ===================================================================
; AtualizaTempo: Incrementa o contador de ciclos e atualiza Tempo
; Cada vez que TempoContador chega em 15, incrementa Tempo (1 segundo)
; ===================================================================
AtualizaTempo:
    push r0
    push r1

    load r0, TempoContador
    inc r0

    loadn r1, #50000         ; Ajuste esse valor se precisar deixar mais rápido ou mais devagar
    cmp r0, r1
    jne AtualizaTempo_Salva

    ; Chegou no limite: incrementa o tempo e reseta o contador
    loadn r0, #0
    load r1, Tempo
    inc r1

    ; Limita o tempo em 999 para não estourar 3 dígitos
    loadn r0, #999
    cmp r1, r0
    jle AtualizaTempo_SalvaTempo
    loadn r1, #999

AtualizaTempo_SalvaTempo:
    store Tempo, r1
    loadn r0, #0
    
    call ImprimeContadores ; Atualiza a tela com o novo tempo

AtualizaTempo_Salva:
    store TempoContador, r0

    pop r1
    pop r0
    rts

; ===================================================================
; ImprimeContadores: Desenha o contador de bandeiras e o timer
; Posição: Row 0 da tela, acima do tabuleiro
; Bandeira à esquerda (col 11), Relogio à direita (col 25)
; ===================================================================
ImprimeContadores:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5

    ; ===== CONTADOR DE BANDEIRAS (esquerda) =====
    ; Imprime o ícone da bandeira (char 8) na posição 11 (row 0, col 11)
    loadn r0, #8            ; char da bandeira
    loadn r1, #11           ; posição na tela
    outchar r0, r1

    ; Limpa o sinal de menos (imprime espaço) na posição 12
    loadn r5, #' '
    loadn r1, #12
    outchar r5, r1

    ; Carrega BandeirasRestantes
    load r0, BandeirasRestantes

    ; Checa se é negativo (verifica o bit 15)
    loadn r1, #32768
    and r1, r0, r1
    jz ImprimeContadores_BandPos

    ; Negativo: faz 0 - r0 para obter o absoluto
    loadn r1, #0
    sub r0, r1, r0

    ; E imprime o sinal de menos
    loadn r5, #'-'
    loadn r1, #12
    outchar r5, r1

ImprimeContadores_BandPos:
    ; r0 = valor absoluto (0..99 na prática)
    ; Extrai dezena: quantas vezes cabe 10
    loadn r2, #0            ; r2 = dezena
    loadn r3, #10
ImprimeContadores_BandDezLoop:
    cmp r3, r0
    jgr ImprimeContadores_BandDezFim  ; se 10 > r0 (r0 < 10), parou
    sub r0, r0, r3
    inc r2
    jmp ImprimeContadores_BandDezLoop

ImprimeContadores_BandDezFim:
    ; r2 = dezena, r0 = unidade
    loadn r4, #48           ; offset ASCII '0'

    ; Imprime dezena na posição 13
    add r5, r2, r4
    loadn r1, #13
    outchar r5, r1

    ; Imprime unidade na posição 14
    add r5, r0, r4
    loadn r1, #14
    outchar r5, r1

    ; ===== CONTADOR DE TEMPO (direita) =====
    ; Imprime o ícone do relógio (char 123) na posição 24
    loadn r0, #123          ; char do relógio
    loadn r1, #24
    outchar r0, r1

    ; Limpa o espaço (deixa preto) na posição 25, entre o relógio e os números
    loadn r5, #' '
    loadn r1, #25
    outchar r5, r1

    ; Carrega Tempo
    load r0, Tempo

    ; Extrai centena
    loadn r2, #0            ; r2 = centena
    loadn r3, #100
ImprimeContadores_TempCentLoop:
    cmp r3, r0
    jgr ImprimeContadores_TempCentFim  ; se 100 > r0 (r0 < 100), parou
    sub r0, r0, r3
    inc r2
    jmp ImprimeContadores_TempCentLoop

ImprimeContadores_TempCentFim:
    ; r2 = centena, r0 = resto (0..99)

    ; Extrai dezena
    loadn r3, #0            ; r3 = dezena
    loadn r4, #10
ImprimeContadores_TempDezLoop:
    cmp r4, r0
    jgr ImprimeContadores_TempDezFim  ; se 10 > r0 (r0 < 10), parou
    sub r0, r0, r4
    inc r3
    jmp ImprimeContadores_TempDezLoop

ImprimeContadores_TempDezFim:
    ; r2 = centena, r3 = dezena, r0 = unidade
    loadn r4, #48           ; offset ASCII '0'

    ; Imprime centena do tempo na posição 26
    add r5, r2, r4
    loadn r1, #26
    outchar r5, r1

    ; Imprime dezena do tempo na posição 27
    add r5, r3, r4
    loadn r1, #27
    outchar r5, r1

    ; Imprime unidade do tempo na posição 28
    add r5, r0, r4
    loadn r1, #28
    outchar r5, r1

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts



; ===================================================================
; TelaFinal: Mostra o resultado e trava o jogo
; Sugestao de responsavel: Covisi
; ===================================================================
TelaFinal:
    ; Verifica se ganhou ou perdeu
    load r0, GameOver
    loadn r1, #1
    cmp r0, r1
    jeq TelaFinal_Derrota
    
    loadn r1, #2
    cmp r0, r1
    jeq TelaFinal_Vitoria
    
    rts

TelaFinal_Derrota:
    call printcenarioDerrotaScreen    ; Limpa a tela mostrando a tela de derrota
    
    loadn r0, #MsgDerrota
    loadn r1, #1000      ; Linha 25
    call ImprimeStr
    
    jmp TelaFinal_EsperaTecla

TelaFinal_Vitoria:
    call printcenario1Screen
    
    loadn r0, #MsgVitoria
    loadn r1, #1000
    call ImprimeStr

TelaFinal_EsperaTecla:
    loadn r0, #MsgTelaInicial
    loadn r1, #1120             ; Linha 28
    call ImprimeStr
    
    push r0
    push r1
    
    ; Espera soltar todas as teclas primeiro para nao pegar sujeira do jogo
    loadn r1, #255
TelaFinal_LimpaBuffer:
    inchar r0
    cmp r0, r1
    jne TelaFinal_LimpaBuffer

TelaFinal_Loop:
    inchar r0
    cmp r0, r1
    jeq TelaFinal_Loop          ; Espera apertar algo
    
    pop r1
    pop r0
    
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
