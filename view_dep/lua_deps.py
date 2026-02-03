import os
import re

# Adjust this to point to your Lua source folder
ROOT = "./"

require_pattern = re.compile(r'require\s*\(\s*["\']([^"\']+)["\']\s*\)')

def find_lua_files(root):
    for dirpath, _, filenames in os.walk(root):
        for f in filenames:
            if f.endswith(".lua"):
                yield os.path.join(dirpath, f)

def module_name_from_path(path):
    # Convert "folder/file.lua" → "folder.file"
    rel = os.path.relpath(path, ROOT)
    return rel[:-4].replace(os.sep, ".")

edges = []

for file in find_lua_files(ROOT):
    module = module_name_from_path(file)
    with open(file, "r", encoding="utf-8") as f:
        text = f.read()
        for req in require_pattern.findall(text):
            edges.append((module, req))

# Output Graphviz DOT
print("digraph lua_deps {")
print('  rankdir=LR;')
for a, b in edges:
    print(f'  "{a}" -> "{b}";')
print("}")
