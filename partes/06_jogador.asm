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
    ; O QUE FAZER:
    ; 1. Ler a variavel 'Letra'.
    ; 2. Se for a tecla 'f': Vai na posicao atual no Tabuleiro e inverte o Bit 2 (Bandeira).
    ; 3. Se for ' ' (Espaco): Vai na posicao atual no Tabuleiro.
    ;    - Liga o Bit 1 (Revelado).
    ;    - Checa o Bit 0 (Bomba). Se tiver bomba, seta GameOver = 1 (Perdeu).
    ;    - Se revelar a ultima casa vazia do mapa, seta GameOver = 2 (Venceu).
    rts
