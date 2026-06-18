import re

with open("partes/04_tabuleiro.asm", "r") as f:
    lines = f.readlines()

out = []
in_draw_logic = False
imprime_casa_lines = []

for line in lines:
    if "ImprimeTabuleiro_LoopX:" in line:
        out.append(line)
        continue
    if "; --- Draw logic ---" in line:
        in_draw_logic = True
        out.append("    push r2\n")
        out.append("    loadn r2, #0\n")
        out.append("    call ImprimeCasa\n")
        out.append("    pop r2\n\n")
        continue
    if in_draw_logic and "ImprimeTabuleiro_Prox:" in line:
        in_draw_logic = False
        out.append(line)
        continue
    
    if in_draw_logic:
        # Save lines for ImprimeCasa
        imprime_casa_lines.append(line)
    else:
        out.append(line)

# Process imprime_casa_lines
casa_out = []
casa_out.append("; ===================================================================\n")
casa_out.append("; ImprimeCasa: Desenha uma casa especifica na tela\n")
casa_out.append("; r0 = indice da casa (0 a 99)\n")
casa_out.append("; r3 = offset na tela inicial da casa\n")
casa_out.append("; r2 = offset de cor\n")
casa_out.append("; ===================================================================\n")
casa_out.append("ImprimeCasa:\n")
casa_out.append("    push r4\n")
casa_out.append("    push r5\n")
casa_out.append("    push r6\n")
casa_out.append("    push r7\n\n")

for line in imprime_casa_lines:
    line = line.replace("ImprimeTabuleiro_", "ImprimeCasa_")
    
    if "outchar r5" in line:
        casa_out.append("    add r5, r5, r2\n")
    
    casa_out.append(line)

casa_out.append("ImprimeCasa_Fim:\n")
casa_out.append("    pop r7\n")
casa_out.append("    pop r6\n")
casa_out.append("    pop r5\n")
casa_out.append("    pop r4\n")
casa_out.append("    rts\n\n")

with open("partes/04_tabuleiro.asm", "w") as f:
    f.writelines(out + casa_out)

