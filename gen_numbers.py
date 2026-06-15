def print_char(name, idx, matrix):
    res = f"-- [{idx}]     {name}\n"
    for i in range(8):
        res += f"\t{idx*8+i}  :   {matrix[i]};\n"
    res += "\n"
    return res

def make_num(grid14x14):
    # top-left (num4), top-right (num3), bottom-left (num1), bottom-right (num2)
    tl = ["11111111", "10000000"]
    for r in range(6):
        tl.append("1" + grid14x14[r][:7])
        
    tr = ["11111111", "00000001"]
    for r in range(6):
        tr.append(grid14x14[r][7:] + "1")
        
    bl = []
    for r in range(6, 12):
        bl.append("1" + grid14x14[r][:7])
    bl.append("10000000")
    bl.append("11111111")
    
    br = []
    for r in range(6, 12):
        br.append(grid14x14[r][7:] + "1")
    br.append("00000001")
    br.append("11111111")
    
    return [bl, br, tr, tl] # 1, 2, 3, 4

# The user's bottom half for 2:
# R8:  ....... 0110000 (10000000 00110001) -> ...11..
# R9:  ......1 1100000 (10000001 11100001) -> ......1 11.....
# R10: ....111 1000000 (10000111 11000001) -> ....111 1......
# R11: ...1100 0000000 (10001100 00000001) -> ...11.. .......
# R12: ...1100 0000000 (10001100 00000001) -> ...11.. .......
# R13: ....111 1110000 (10000111 11110001) -> ....111 111....

dois_bottom = [
    "00000000110000",
    "00000011100000",
    "00001111000000",
    "00011000000000",
    "00011000000000",
    "00001111110000"
]

dois_top = [
    "00000000000000",
    "00001111100000",
    "00011000110000",
    "00011000011000",
    "00000000011000",
    "00000000110000"
]
dois = dois_top + dois_bottom

tres = [
    "00000000000000",
    "00001111100000",
    "00011000110000",
    "00000000110000",
    "00000011100000",
    "00000011100000",
    "00000000110000",
    "00000000110000",
    "00011000110000",
    "00011000110000",
    "00001111100000",
    "00000000000000"
]

quatro = [
    "00000000110000",
    "00000001110000",
    "00000011110000",
    "00000110110000",
    "00001100110000",
    "00011000110000",
    "00111111111000",
    "00000000110000",
    "00000000110000",
    "00000000110000",
    "00000000110000",
    "00000000000000"
]

cinco = [
    "00000000000000",
    "00011111110000",
    "00011000000000",
    "00011000000000",
    "00011111100000",
    "00000000110000",
    "00000000110000",
    "00000000110000",
    "00011000110000",
    "00011000110000",
    "00001111100000",
    "00000000000000"
]

seis = [
    "00000000000000",
    "00000111100000",
    "00001100110000",
    "00011000000000",
    "00011000000000",
    "00011111100000",
    "00011000110000",
    "00011000110000",
    "00011000110000",
    "00001100110000",
    "00000111100000",
    "00000000000000"
]

sete = [
    "00000000000000",
    "00011111110000",
    "00000000110000",
    "00000000110000",
    "00000001100000",
    "00000011000000",
    "00000011000000",
    "00000110000000",
    "00000110000000",
    "00001100000000",
    "00001100000000",
    "00000000000000"
]

oito = [
    "00000000000000",
    "00001111100000",
    "00011000110000",
    "00011000110000",
    "00011000110000",
    "00001111100000",
    "00011000110000",
    "00011000110000",
    "00011000110000",
    "00011000110000",
    "00001111100000",
    "00000000000000"
]

chars = []
# 2
dois_pieces = make_num(dois)
chars.append(("dois3", 23, dois_pieces[2]))
chars.append(("dois4", 24, dois_pieces[3]))

# 3
tres_pieces = make_num(tres)
chars.append(("tres1", 25, tres_pieces[0]))
chars.append(("tres2", 26, tres_pieces[1]))
chars.append(("tres3", 27, tres_pieces[2]))
chars.append(("tres4", 28, tres_pieces[3]))

# 4
quatro_pieces = make_num(quatro)
chars.append(("quatro1", 29, quatro_pieces[0]))
chars.append(("quatro2", 30, quatro_pieces[1]))
chars.append(("quatro3", 32, quatro_pieces[2]))
chars.append(("quatro4", 33, quatro_pieces[3]))

# 5
cinco_pieces = make_num(cinco)
chars.append(("cinco1", 34, cinco_pieces[0]))
chars.append(("cinco2", 35, cinco_pieces[1]))
chars.append(("cinco3", 36, cinco_pieces[2]))
chars.append(("cinco4", 37, cinco_pieces[3]))

# 6
seis_pieces = make_num(seis)
chars.append(("seis1", 38, seis_pieces[0]))
chars.append(("seis2", 39, seis_pieces[1]))
chars.append(("seis3", 40, seis_pieces[2]))
chars.append(("seis4", 41, seis_pieces[3]))

# 7
sete_pieces = make_num(sete)
chars.append(("sete1", 42, sete_pieces[0]))
chars.append(("sete2", 43, sete_pieces[1]))
chars.append(("sete3", 44, sete_pieces[2]))
chars.append(("sete4", 45, sete_pieces[3]))

# 8
oito_pieces = make_num(oito)
chars.append(("oito1", 46, oito_pieces[0]))
chars.append(("oito2", 47, oito_pieces[1]))
chars.append(("oito3", 48, oito_pieces[2]))
chars.append(("oito4", 49, oito_pieces[3]))

out = ""
for c in chars:
    out += print_char(c[0], c[1], c[2])
    
with open("new_chars.txt", "w") as f:
    f.write(out)
