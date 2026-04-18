#!/bin/bash
./montador $1.asm $1.mif
./sim $1.mif charmap.mif

#para executar use: 
#./rodar.sh [nome do arquivo sem extensao]