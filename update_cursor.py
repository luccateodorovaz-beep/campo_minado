with open("partes/05_cursor.asm", "r") as f:
    lines = f.readlines()

out = []
in_draw_logic = False
for line in lines:
    if "; top-left: cursor4 (char 16)" in line:
        in_draw_logic = True
        out.append("    load r0, PosCursor  ; Restaura r0 para o indice logico\n")
        out.append("    loadn r2, #512      ; Cor verde (bit 9 = 1 -> +512)\n")
        out.append("    push r3\n")
        out.append("    push r6\n")
        out.append("    pop r3              ; ImprimeCasa usa r3 para offset na tela\n")
        out.append("    call ImprimeCasa\n")
        out.append("    pop r3\n\n")
        continue
        
    if in_draw_logic and line.strip() == "pop r6":
        in_draw_logic = False
        out.append(line)
        continue
        
    if not in_draw_logic:
        out.append(line)

with open("partes/05_cursor.asm", "w") as f:
    f.writelines(out)

