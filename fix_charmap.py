import re

with open("charmap.mif", "r") as f:
    charmap = f.read()

# Original 1
char_1 = """-- [49]     1
\t392  :   00011000;
\t393  :   00011000;
\t394  :   00111000;
\t395  :   00011000;
\t396  :   00011000;
\t397  :   00011000;
\t398  :   01111110;
\t399  :   00000000;"""

# oito4 moved to 58
char_oito4 = """-- [58]     oito4
\t464  :   11111111;
\t465  :   10000000;
\t466  :   10000000;
\t467  :   10000111;
\t468  :   10001100;
\t469  :   10001100;
\t470  :   10001100;
\t471  :   10000111;"""

# Replace block 49
pattern_49 = re.compile(r"-- \[49\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
charmap = pattern_49.sub(char_1 + "\n\n", charmap)

# Replace block 58
pattern_58 = re.compile(r"-- \[58\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
charmap = pattern_58.sub(char_oito4 + "\n\n", charmap)

with open("charmap.mif", "w") as f:
    f.write(charmap)
