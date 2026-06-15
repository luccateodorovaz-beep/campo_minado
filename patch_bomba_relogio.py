import re

def print_char(name, idx, matrix):
    res = f"-- [{idx}]     {name}\n"
    for i in range(8):
        res += f"\t{idx*8+i}  :   {matrix[i]};\n"
    return res

def make_num(grid14x14):
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

bomba_grid = [
    "00000010000000",
    "00000100000000",
    "00001000000000",
    "00001111110000",
    "00011111111000",
    "00111100111100",
    "00111000011100",
    "01111000011110",
    "01111100111110",
    "01111111111110",
    "00111111111100",
    "00111111111100",
    "00011111111000",
    "00001111110000"
]

bomba_pieces = make_num(bomba_grid)

relogio_grid = [
    "00111100",
    "01000010",
    "10010001",
    "10010001",
    "10011101",
    "10000001",
    "01000010",
    "00111100"
]

blocks = {
    59: print_char("bomba1", 59, bomba_pieces[0]),
    60: print_char("bomba2", 60, bomba_pieces[1]),
    61: print_char("bomba3", 61, bomba_pieces[2]),
    62: print_char("bomba4", 62, bomba_pieces[3]),
    123: print_char("relogio", 123, relogio_grid)
}

with open("charmap.mif", "r") as f:
    charmap = f.read()

for idx, new_content in blocks.items():
    pattern = re.compile(rf"-- \[{idx}\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
    if pattern.search(charmap):
        charmap = pattern.sub(new_content.strip() + "\n\n", charmap)
    else:
        print(f"Could not find block {idx}")

with open("charmap.mif", "w") as f:
    f.write(charmap)
