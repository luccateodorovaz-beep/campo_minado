#!/bin/bash
cat partes/01_variaveis.asm \
    partes/02_main.asm \
    partes/03_inicializa.asm \
    partes/04_tabuleiro.asm \
    partes/05_cursor.asm \
    partes/06_jogador.asm \
    partes/07_misc.asm \
    partes/08_cenario.asm > campominado.asm

./montador campominado.asm campominado.mif
./sim campominado.mif charmap.mif

#para executar use:
#./rodar.sh
