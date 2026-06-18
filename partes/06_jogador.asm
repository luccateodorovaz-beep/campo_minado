; ===================================================================
; LeTeclado: Captura a tecla pressionada sem travar o jogo
; Sugestao de responsavel: Covisi
; Feito por: Antonio
; ===================================================================
LeTeclado:
    push r0

    inchar r0               ; lê o teclado sem travar (255 = nenhuma tecla)
    store Letra, r0         ; grava sempre: seja 255 ou uma tecla real

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

    loadn r0,#'f'        ; tecla 'f' (adicionar/remover flag)
    loadn r1,#' '        ; tecla espaço (revelar posição atual)

LoopAcaoJogador:
    ; Verifica qual tecla foi pressionada
    load r3, Letra       ; lê tecla atual
    cmp r0, r3
    jeq AcaoF
    cmp r3, r1
    jeq AcaoEspaco
    jne FinalAcaoJogador ; se não for nem 'f' nem espaço, retorna

; --- AcaoF: alterna bandeira na casa atual ---
AcaoF:
    load r0, PosCursor
    loadn r1,#Tabuleiro
    add r1, r1, r0
    loadi r4, r1
    loadn r2,#4           ; máscara do bit da flag (00000100)
    xor r3, r2, r4
    storei r1, r3
    jmp FinalAcaoJogador

; --- AcaoEspaco: revela a casa atual ---
AcaoEspaco:
    load r0, PrimeiraJogada
    loadn r1, #1
    cmp r0, r1
    jne AcaoEspaco_PulaGeraBombas

    ; primeira jogada
    loadn r1, #0
    store PrimeiraJogada, r1
    call GeraBombas
    call CalculaDicas

AcaoEspaco_PulaGeraBombas:
    load r0, PosCursor
    loadn r1, #Tabuleiro
    add r1, r1, r0
    loadi r4, r1          ; r4 = valor da casa atual

ChecaBit0:
    loadn r2, #1
    and r3, r4, r2
    jnz SetGameOverLose   ; bomba -> perde

    ; já está revelada? (bit 1 ligado) -> nada a fazer
    loadn r2, #2
    and r3, r4, r2
    jnz FinalAcaoJogador  ; já revelada, sai sem alterar

LigaBit1:
    loadn r5, #2
    or r6, r4, r5
    storei r1, r6

    load r7, CasasSeguras
    dec r7
    store CasasSeguras, r7

    call ExpandeZeros

    jmp FinalAcaoJogador

; ===================================================================
; ExpandeZeros: Varre o tabuleiro iterativamente abrindo vizinhos
; Inclui expansão nas 8 direções: ortogonais e diagonais.
; O loop percorre o tabuleiro a cada iteração; se algo abriu (r0=1), repete.
; ===================================================================
ExpandeZeros:
    push r0    ; r0 = flag de alteração (0 = sem novas casas, 1 = abriu nova casa)
    push r1    ; r1 = índice atual da varredura (0..99)
    push r2    ; r2 = endereço base do tabuleiro
    push r3    ; r3 = endereço da casa atual (Tabuleiro + índice)
    push r4    ; r4 = valor da casa atual
    push r5    ; r5 = auxiliar
    push r6    ; r6 = índice do vizinho a ser testado
    push r7    ; r7 = coluna atual (r1 mod 10)

LoopVarreduraGeral:
    loadn r0, #0
    loadn r1, #0
    loadn r2, #Tabuleiro

LoopPercorreCasas:
    loadn r5, #100
    cmp r1, r5
    jeq FimPercorreCasas    ; varreu todo o tabuleiro

    add r3, r2, r1          ; r3 = endereço da posição atual
    loadi r4, r3            ; r4 = conteúdo da casa

    ; --- Teste 1: a casa está REVELADA? ---
    loadn r5, #2
    and r5, r4, r5
    jz EZ_ProximaCasa       ; se não estiver revelada, pula

    ; --- Teste 2: a casa tem ZERO bombas ao redor? ---
    ; bits de números vão do bit 3 até o 6 (máscara 0b01111000 = 120)
    loadn r5, #120
    and r5, r4, r5
    jnz EZ_ProximaCasa      ; se não-zero, tem número -> pula

    ; é uma casa revelada com valor ZERO -> tenta abrir os 8 vizinhos
    call DescobreColuna     ; r7 = coluna atual (0..9)

    ; 1) vizinho cima (-10)
    loadn r5, #9
    cmp r1, r5
    jle PulaCima
    loadn r5, #10
    sub r6, r1, r5
    call TentaAbrirVizinho
PulaCima:

    ; 2) vizinho baixo (+10)
    loadn r5, #89
    cmp r1, r5
    jgr PulaBaixo
    loadn r5, #10
    add r6, r1, r5
    call TentaAbrirVizinho
PulaBaixo:

    ; 3) vizinho esquerda (-1)
    loadn r5, #0
    cmp r7, r5             ; r7 = coluna
    jeq PulaEsquerda
    loadn r5, #1
    sub r6, r1, r5
    call TentaAbrirVizinho
PulaEsquerda:

    ; 4) vizinho direita (+1)
    loadn r5, #9
    cmp r7, r5
    jeq PulaDireita
    loadn r5, #1
    add r6, r1, r5
    call TentaAbrirVizinho
PulaDireita:

    ; 5) diagonal cima-esquerda (-11)
    loadn r5, #9
    cmp r1, r5
    jle PulaDiagCimaEsq
    loadn r5, #0
    cmp r7, r5
    jeq PulaDiagCimaEsq
    loadn r5, #11
    sub r6, r1, r5
    call TentaAbrirVizinho
PulaDiagCimaEsq:

    ; 6) diagonal cima-direita (-9)
    loadn r5, #9
    cmp r1, r5
    jle PulaDiagCimaDir
    loadn r5, #9
    cmp r7, r5
    jeq PulaDiagCimaDir
    loadn r5, #9
    sub r6, r1, r5
    call TentaAbrirVizinho
PulaDiagCimaDir:

    ; 7) diagonal baixo-esquerda (+9)
    loadn r5, #89
    cmp r1, r5
    jgr PulaDiagBaixoEsq
    loadn r5, #0
    cmp r7, r5
    jeq PulaDiagBaixoEsq
    loadn r5, #9
    add r6, r1, r5
    call TentaAbrirVizinho
PulaDiagBaixoEsq:

    ; 8) diagonal baixo-direita (+11)
    loadn r5, #89
    cmp r1, r5
    jgr PulaDiagBaixoDir
    loadn r5, #9
    cmp r7, r5
    jeq PulaDiagBaixoDir
    loadn r5, #11
    add r6, r1, r5
    call TentaAbrirVizinho
PulaDiagBaixoDir:

    jmp EZ_ProximaCasa

EZ_ProximaCasa:
    loadn r5, #1
    add r1, r1, r5           ; r1++
    jmp LoopPercorreCasas

FimPercorreCasas:
    loadn r5, #1
    cmp r0, r5
    jeq LoopVarreduraGeral  ; se r0==1 -> repetir varredura

    ; fim da expansão: restaura registradores e retorna
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
; Rotinas Auxiliares da Expansão
; ===================================================================

; DescobreColuna: guarda em r7 a coluna atual (r1 mod 10)
DescobreColuna:
    push r5
    loadn r5, #10
    mod r7, r1, r5          ; resto da divisão -> coluna
    pop r5
    rts

; TentaAbrirVizinho: abre a casa vizinha se estiver fechada e não for bomba
TentaAbrirVizinho:
    push r3
    push r4
    push r5

    add r3, r2, r6          ; endereço da casa vizinha
    loadi r4, r3            ; valor da vizinha

    ; já está aberta?
    loadn r5, #2
    and r5, r4, r5
    jnz FimTentaAbrir       ; se sim, sai

    ; é uma bomba? (bit 0 ligado) -> não abre no flood fill
    loadn r5, #1
    and r5, r4, r5
    jnz FimTentaAbrir       ; se for bomba, sai sem abrir

    ; abre a casa (liga bit 1)
    loadn r5, #2
    or r4, r4, r5
    storei r3, r4

    ; decrementa CasasSeguras
    push r7
    load r7, CasasSeguras
    dec r7
    store CasasSeguras, r7
    pop r7

    ; avisa que houve alteração (força nova varredura)
    loadn r0, #1

FimTentaAbrir:
    pop r5
    pop r4
    pop r3
    rts

; ===================================================================
; Condições finais do jogo
; ===================================================================

SetGameOverLose:
    loadn r2, #1
    store GameOver, r2
    jmp FinalAcaoJogador

SetGameOverWin:
    loadn r2, #2
    store GameOver, r2
    jmp FinalAcaoJogador

FinalAcaoJogador:
    ; Restaura todos os registradores salvos no topo de AcaoJogador
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
