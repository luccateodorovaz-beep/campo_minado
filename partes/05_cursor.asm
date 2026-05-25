; ===================================================================
; DesenhaCursor: Destaca a posicao atual do jogador na tela
; Sugestao de responsavel: Lucca
;
; ===================================================================
DesenhaCursor:
    ; O QUE FAZER:
    ; 1. Ler a variavel 'PosCursor'.
    ; 2. Calcular onde isso fica na tela (mesma matematica do ImprimeTabuleiro).
    ; 3. Mudar a cor do caractere ou desenhar um cursor visual (ex: '< >' em volta).
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

    loadn r2, #10
    add r2, r1, r2              ; r2 = nova posicao (pos + 10)
    loadn r3, #99
    cmp r2, r3
    jgr MoveCursor_Fim          ; nova pos > 99 → ja esta na ultima linha, nao move

    store PosAntCursor, r1
    store PosCursor, r2         ; desce uma linha
    jmp MoveCursor_Fim

    ; ------------------------------------------------------------------
    ; A — mover para ESQUERDA (subtrai 1)
    ; Protecao de borda: nao pode sair da coluna 0 (pos MOD 10 == 0)
    ; ------------------------------------------------------------------
MoveCursor_A:
    loadn r2, #'a'
    cmp r0, r2
    jne MoveCursor_D            ; nao e 'a', testa proximo

    ; calcula a coluna atual = PosCursor MOD 10
    load r3, PosCursor
MoveCursor_A_Mod:
    loadn r2, #9
    cmp r3, r2
    jle MoveCursor_A_ModFim     ; r3 <= 9 → r3 ja e a coluna
    loadn r2, #10
    sub r3, r3, r2              ; r3 -= 10
    jmp MoveCursor_A_Mod
MoveCursor_A_ModFim:
    loadn r2, #0
    cmp r3, r2
    jeq MoveCursor_Fim          ; coluna == 0 → borda esquerda, nao move

    store PosAntCursor, r1
    dec r1                      ; anda um passo a esquerda: pos = pos - 1
    store PosCursor, r1
    jmp MoveCursor_Fim

    ; ------------------------------------------------------------------
    ; D — mover para DIREITA (soma 1)
    ; Protecao de borda: nao pode sair da coluna 9 (pos MOD 10 == 9)
    ; ------------------------------------------------------------------
MoveCursor_D:
    loadn r2, #'d'
    cmp r0, r2
    jne MoveCursor_Fim          ; nao e 'd', nenhuma tecla valida

    ; calcula a coluna atual = PosCursor MOD 10
    load r3, PosCursor
MoveCursor_D_Mod:
    loadn r2, #9
    cmp r3, r2
    jle MoveCursor_D_ModFim     ; r3 <= 9 → r3 ja e a coluna
    loadn r2, #10
    sub r3, r3, r2              ; r3 -= 10
    jmp MoveCursor_D_Mod
MoveCursor_D_ModFim:
    loadn r2, #9
    cmp r3, r2
    jeq MoveCursor_Fim          ; coluna == 9 → borda direita, nao move

    store PosAntCursor, r1
    inc r1                      ; anda um passo a direita: pos = pos + 1
    store PosCursor, r1

MoveCursor_Fim:
    pop r3
    pop r2
    pop r1
    pop r0
    rts
