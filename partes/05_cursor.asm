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
