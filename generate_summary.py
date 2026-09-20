#!/usr/bin/env python3
"""
Project Directory Summary Generator
Generates a comprehensive text-based map of a LÖVE2D project for LLM context.
"""

import os
import re
import sys

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
OUTPUT_FILE = os.path.join(PROJECT_ROOT, "PROJECT_SUMMARY.txt")
MAX_SNIPPET_LINES = 30
EXCLUDE_DIRS = {".git", ".kilo", "libs"}  # Exclude VCS, config, and third-party libs
LUA_EXT = ".lua"


def build_tree(root_path):
    """Build a directory tree string, excluding specified directories."""
    lines = []
    root_name = os.path.basename(root_path) or root_path
    lines.append(f"{root_name}/")

    def walk(dir_path, prefix=""):
        try:
            entries = sorted(os.listdir(dir_path))
        except OSError:
            return

        dirs = [e for e in entries if os.path.isdir(os.path.join(dir_path, e)) and e not in EXCLUDE_DIRS]
        files = [e for e in entries if os.path.isfile(os.path.join(dir_path, e))]

        for i, d in enumerate(dirs):
            connector = "└── " if i == len(dirs) - 1 and not files else "├── "
            lines.append(f"{prefix}{connector}{d}/")
            extension = "    " if (i == len(dirs) - 1 and not files) else "│   "
            walk(os.path.join(dir_path, d), prefix + extension)

        for i, f in enumerate(files):
            connector = "└── " if i == len(files) - 1 else "├── "
            lines.append(f"{prefix}{connector}{f}")

    walk(root_path)
    return "\n".join(lines)


def extract_file_overview(file_path):
    """
    Extract a brief overview from a Lua file.
    Returns a list of meaningful lines: comments, function/class defs, module declarations.
    """
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
    except OSError:
        return ["[Error reading file]"]

    overview = []
    in_initial_comment_block = False

    for line in lines[:MAX_SNIPPET_LINES]:
        stripped = line.rstrip()
        if not stripped:
            continue

        # Collect comment lines
        if stripped.startswith("--"):
            overview.append(stripped)
            in_initial_comment_block = True
            continue

        # Once we've hit code, collect key definitions but stop after a reasonable amount
        if in_initial_comment_block:
            if re.match(r'^(local\s+\w+|function\s+\w+|return\s+\w)', stripped):
                overview.append(stripped)
            elif re.match(r'^(\w+\s*=\s*\{|\w+\s*=\s*require)', stripped):
                overview.append(stripped)
            if len(overview) >= 12:
                break
        else:
            # No initial comment block; collect the first few meaningful definitions
            if re.match(r'^(local\s+\w+|function\s+\w+|return\s+\w)', stripped):
                overview.append(stripped)
            elif re.match(r'^(\w+\s*=\s*\{|\w+\s*=\s*require)', stripped):
                overview.append(stripped)
            if len(overview) >= 8:
                break

    # If file is very short, include all lines
    if len(lines) <= MAX_SNIPPET_LINES and not overview:
        overview = [l.rstrip() for l in lines if l.strip()]

    # Clean up trailing empties
    while overview and not overview[-1].strip():
        overview.pop()

    return overview if overview else ["[No extractable overview]"]


def main():
    print(f"Scanning project: {PROJECT_ROOT}")

    # Build tree
    tree = build_tree(PROJECT_ROOT)

    # Collect all Lua files (relative paths)
    lua_files = []
    for root, dirs, files in os.walk(PROJECT_ROOT):
        # Modify dirs in-place to prevent walking into excluded dirs
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for f in files:
            if f.endswith(LUA_EXT):
                abs_path = os.path.join(root, f)
                rel_path = os.path.relpath(abs_path, PROJECT_ROOT)
                lua_files.append(rel_path)

    lua_files.sort()

    # Build output
    output_lines = []
    output_lines.append("=" * 80)
    output_lines.append("PROJECT DIRECTORY SUMMARY")
    output_lines.append(f"Root: {PROJECT_ROOT}")
    output_lines.append(f"Total Lua files: {len(lua_files)}")
    output_lines.append("=" * 80)
    output_lines.append("")
    output_lines.append("DIRECTORY STRUCTURE")
    output_lines.append("-" * 80)
    output_lines.append(tree)
    output_lines.append("")
    output_lines.append("=" * 80)
    output_lines.append("FILE OVERVIEWS")
    output_lines.append("=" * 80)

    for rel_path in lua_files:
        abs_path = os.path.join(PROJECT_ROOT, rel_path)
        output_lines.append("")
        output_lines.append(f"FILE: {rel_path}")
        output_lines.append("-" * 80)

        overview = extract_file_overview(abs_path)
        for line in overview:
            output_lines.append(line)

    output_lines.append("")
    output_lines.append("=" * 80)
    output_lines.append("END OF SUMMARY")
    output_lines.append("=" * 80)

    # Write output
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines) + "\n")

    print(f"Summary written to: {OUTPUT_FILE}")
    print(f"Files processed: {len(lua_files)}")


if __name__ == "__main__":
    main()
