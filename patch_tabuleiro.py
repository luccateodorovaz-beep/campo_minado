import re

asm = """    ; --- Draw logic ---
    loadn r5, #Tabuleiro
    add r5, r5, r0
    loadi r4, r5        ; r4 recebe o valor que esta no Tabuleiro
    
    ; check Revealed (bit 1)
    loadn r5, #2
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jne ImprimeTabuleiro_Revelado

ImprimeTabuleiro_NaoRevelado:
    ; check Bandeira (bit 2)
    loadn r5, #4
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jeq ImprimeTabuleiro_Vazio
    jmp ImprimeTabuleiro_Flag

ImprimeTabuleiro_Revelado:
    ; check Bomb (bit 0)
    loadn r5, #1
    and r5, r4, r5
    loadn r7, #0
    cmp r5, r7
    jne ImprimeTabuleiro_Bomba

    ; mask hint (bits 3 to 6)
    loadn r5, #120      ; 1111000 in binary
    and r7, r4, r5
    
    loadn r5, #0
    cmp r7, r5
    jeq ImprimeTabuleiro_Zero
    
    loadn r5, #8
    cmp r7, r5
    jeq ImprimeTabuleiro_Um
    
    loadn r5, #16
    cmp r7, r5
    jeq ImprimeTabuleiro_Dois
    
    loadn r5, #24
    cmp r7, r5
    jeq ImprimeTabuleiro_Tres
    
    loadn r5, #32
    cmp r7, r5
    jeq ImprimeTabuleiro_Quatro
    
    loadn r5, #40
    cmp r7, r5
    jeq ImprimeTabuleiro_Cinco
    
    loadn r5, #48
    cmp r7, r5
    jeq ImprimeTabuleiro_Seis
    
    loadn r5, #56
    cmp r7, r5
    jeq ImprimeTabuleiro_Sete
    
    jmp ImprimeTabuleiro_Oito

"""

def draw_block(label, tl, tr, bl, br):
    return f"""{label}:
    loadn r5, #{tl}
    outchar r5, r3
    
    loadn r5, #{tr}
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    loadn r5, #{bl}
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    loadn r5, #{br}
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

"""

asm += draw_block("ImprimeTabuleiro_Bomba", 62, 61, 59, 60)
asm += draw_block("ImprimeTabuleiro_Zero", 3, 3, 3, 3)
asm += draw_block("ImprimeTabuleiro_Um", 20, 19, 17, 18)
asm += draw_block("ImprimeTabuleiro_Dois", 24, 23, 21, 22)
asm += draw_block("ImprimeTabuleiro_Tres", 28, 27, 25, 26)
asm += draw_block("ImprimeTabuleiro_Quatro", 33, 32, 29, 30)
asm += draw_block("ImprimeTabuleiro_Cinco", 37, 36, 34, 35)
asm += draw_block("ImprimeTabuleiro_Seis", 41, 40, 38, 39)
asm += draw_block("ImprimeTabuleiro_Sete", 45, 44, 42, 43)
asm += draw_block("ImprimeTabuleiro_Oito", 58, 48, 46, 47)

asm += """ImprimeTabuleiro_Flag:
    ; top-left: flag4 (char 12)
    loadn r5, #12
    outchar r5, r3
    
    ; top-right: flag3 (char 11)
    loadn r5, #11
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    ; bottom-left: flag1 (char 9)
    loadn r5, #9
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    ; bottom-right: flag2 (char 10)
    loadn r5, #10
    inc r6
    outchar r5, r6
    
    jmp ImprimeTabuleiro_Prox

ImprimeTabuleiro_Vazio:
    ; top-left: grade4 (char 7)
    loadn r5, #7
    outchar r5, r3
    
    ; top-right: grade3 (char 6)
    loadn r5, #6
    push r3
    pop r6
    inc r6
    outchar r5, r6
    
    ; bottom-left: grade1 (char 31)
    loadn r5, #31
    push r3
    pop r6
    loadn r7, #40
    add r6, r6, r7
    outchar r5, r6
    
    ; bottom-right: grade2 (char 5)
    loadn r5, #5
    inc r6
    outchar r5, r6

ImprimeTabuleiro_Prox:"""

with open("partes/04_tabuleiro.asm", "r") as f:
    code = f.read()

# Replace the block from "; --- Draw logic ---" to "ImprimeTabuleiro_Prox:"
pattern = re.compile(r"    ; --- Draw logic ---.*?ImprimeTabuleiro_Prox:", re.DOTALL)

if pattern.search(code):
    new_code = pattern.sub(asm, code)
    # We must also push r7 at the start of ImprimeTabuleiro and pop it at the end
    # Let's check if r7 is pushed
    if "push r7" not in new_code.split("ImprimeTabuleiro:")[1].split("ImprimeTabuleiro_LoopY:")[0]:
        new_code = new_code.replace("    push r6     ; screen offset helper\n", "    push r6     ; screen offset helper\n    push r7\n")
        new_code = new_code.replace("    pop r6\n    pop r5", "    pop r7\n    pop r6\n    pop r5")

    with open("partes/04_tabuleiro.asm", "w") as f:
        f.write(new_code)
    print("Success")
else:
    print("Pattern not found")

