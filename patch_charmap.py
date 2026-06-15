import re

with open("new_chars.txt", "r") as f:
    new_chars_text = f.read()

# Parse new_chars.txt into a dict
new_blocks = {}
current_idx = None
current_block = []

for line in new_chars_text.splitlines():
    m = re.match(r"-- \[(\d+)\]", line)
    if m:
        if current_idx is not None:
            new_blocks[current_idx] = "\n".join(current_block) + "\n"
        current_idx = int(m.group(1))
        current_block = [line]
    elif current_idx is not None:
        current_block.append(line)

if current_idx is not None:
    new_blocks[current_idx] = "\n".join(current_block) + "\n"

with open("charmap.mif", "r") as f:
    charmap = f.read()

# Replace each block
for idx, new_content in new_blocks.items():
    # Regex to find the block: from -- [idx] up to the next empty line followed by -- or end of file
    pattern = re.compile(rf"-- \[{idx}\].*?(?=\n-- \[\d+\]|\Z)", re.DOTALL)
    if pattern.search(charmap):
        charmap = pattern.sub(new_content.strip() + "\n\n", charmap)
    else:
        print(f"Could not find block {idx}")

with open("charmap.mif", "w") as f:
    f.write(charmap)
