import re

with open("charmap.mif", "r") as f:
    charmap = f.read()

# Extract quatro3 from [32]
pattern_32 = re.compile(r"-- \[32\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
quatro3_match = pattern_32.search(charmap)
if quatro3_match:
    quatro3_block = quatro3_match.group(0)
    # Extract the binary values
    lines = quatro3_block.strip().split('\n')
    binary_values = [line.split(':')[1].strip().strip(';') for line in lines[1:]]
    
    # Restore SPACE at [32]
    space_block = "-- [32]     SPACE\n"
    for i in range(8):
        space_block += f"\t{32*8+i}  :   00000000;\n"
    
    charmap = pattern_32.sub(space_block + "\n", charmap)
    
    # Move quatro3 to [59]
    quatro3_new = "-- [59]     quatro3\n"
    for i in range(8):
        quatro3_new += f"\t{59*8+i}  :   {binary_values[i]};\n"
        
    pattern_59 = re.compile(r"-- \[59\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
    charmap = pattern_59.sub(quatro3_new + "\n", charmap)

with open("charmap.mif", "w") as f:
    f.write(charmap)
