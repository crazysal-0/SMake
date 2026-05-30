import os
import sys
import tomllib as toml
import subprocess


# Load config
try:
    with open("SMake.toml", "rb") as f:
        CONFIG = toml.load(f)

except FileNotFoundError:
    print("Error: SMake.toml not found.")
    sys.exit(1)

except PermissionError:
    print("Error: No permission to read SMake.toml.")
    sys.exit(1)

except IsADirectoryError:
    print("Error: SMake.toml is a directory, not a file.")
    sys.exit(1)

except OSError as e:
    print(f"System error: {e}")
    sys.exit(1)


# Ensure output dirs exist
OBJ_DIR = CONFIG.get("output", {}).get("object_file_directory", "obj")
BIN_PATH = CONFIG.get("output", {}).get("executable", "bin/a.out")

os.makedirs(OBJ_DIR, exist_ok=True)
os.makedirs(os.path.dirname(BIN_PATH), exist_ok=True)


# Helpers
def compile_c():
    c = CONFIG.get("c")
    if not c:
        return []

    compiler = c.get("compiler", "gcc")
    flags = c.get("flags", [])
    sources = c.get("source_files", [])

    objects = []

    for src in sources:
        obj = os.path.join(
            OBJ_DIR,
            os.path.basename(src).replace(".c", ".o")
        )

        cmd = [
            compiler,
            *flags,
            "-c",
            src,
            "-o",
            obj
        ]

        subprocess.run(cmd, check=True)
        objects.append(obj)

    return objects


def assemble():
    asm = CONFIG.get("assembly")
    if not asm:
        return []

    assembler = asm.get("assembler", "nasm")
    flags = asm.get("flags", [])
    sources = asm.get("source_files", [])

    objects = []

    for src in sources:
        obj = os.path.join(
            OBJ_DIR,
            os.path.basename(src).replace(".asm", ".o")
        )

        cmd = [
            assembler,
            *flags,
            src,
            "-o",
            obj
        ]

        subprocess.run(cmd, check=True)
        objects.append(obj)

    return objects


def link(objects):
    linker = CONFIG.get("linker", {}).get("linker", "ld")
    flags = CONFIG.get("linker", {}).get("flags", [])

    cmd = [
        linker,
        *flags,
        *objects,
        "-o",
        BIN_PATH
    ]

    subprocess.run(cmd, check=True)


# Commands
def build():
    objects = []
    objects += compile_c()
    objects += assemble()
    link(objects)


def run():
    build()
    subprocess.run([BIN_PATH])


def clean():
    if os.path.exists(OBJ_DIR):
        for f in os.listdir(OBJ_DIR):
            os.remove(os.path.join(OBJ_DIR, f))

    if os.path.exists(BIN_PATH):
        os.remove(BIN_PATH)


# CLI
if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else "build"

    if command == "build":
        build()
    elif command == "run":
        run()
    elif command == "clean":
        clean()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)