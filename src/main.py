import glob
import os
import subprocess
import sys
import tomllib as toml


try:
    with open("SMake.toml", "rb") as f:
        config = toml.load(f)
except FileNotFoundError:
    print("Error: SMake.toml not found.")
    sys.exit(1)


output = config.get("output", {})

obj_dir = output.get("object_dir", "obj")
binary = output.get("binary")

if not binary:
    print("Error: output.binary is required.")
    sys.exit(1)


os.makedirs(obj_dir, exist_ok=True)

binary_dir = os.path.dirname(binary)
if binary_dir:
    os.makedirs(binary_dir, exist_ok=True)


def resolve(patterns):
    files = []

    for pattern in patterns:
        files.extend(glob.glob(pattern, recursive=True))

    return list(dict.fromkeys(files))


def run(cmd, label=None):
    if label:
        print(label)

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError:
        sys.exit(1)


def object_path(source):
    name = source.replace("\\", "_").replace("/", "_")
    return os.path.join(obj_dir, f"{name}.o")


def compile_c():
    section = config.get("c")

    if not section:
        return []

    compiler = section["compiler"]
    flags = section.get("flags", [])
    sources = resolve(section.get("source_files", []))

    objects = []

    for source in sources:
        obj = object_path(source)

        run(
            [
                compiler,
                *flags,
                "-c",
                source,
                "-o",
                obj
            ],
            f"[C] {source}"
        )

        objects.append(obj)

    return objects


def compile_cpp():
    section = config.get("cpp")

    if not section:
        return []

    compiler = section["compiler"]
    flags = section.get("flags", [])
    sources = resolve(section.get("source_files", []))

    objects = []

    for source in sources:
        obj = object_path(source)

        run(
            [
                compiler,
                *flags,
                "-c",
                source,
                "-o",
                obj
            ],
            f"[CPP] {source}"
        )

        objects.append(obj)

    return objects


def assemble():
    section = config.get("asm")

    if not section:
        return []

    assembler = section["assembler"]
    flags = section.get("flags", [])
    sources = resolve(section.get("source_files", []))

    objects = []

    for source in sources:
        obj = object_path(source)

        run(
            [
                assembler,
                *flags,
                source,
                "-o",
                obj
            ],
            f"[ASM] {source}"
        )

        objects.append(obj)

    return objects


def link(objects):
    if not objects:
        print("Error: no source files found.")
        sys.exit(1)

    section = config.get("link")

    if not section:
        print("Error: missing [link] section.")
        sys.exit(1)

    linker = section["linker"]
    flags = section.get("flags", [])

    run(
        [
            linker,
            *flags,
            *objects,
            "-o",
            binary
        ],
        f"[LINK] {binary}"
    )


def build():
    objects = []

    objects.extend(compile_c())
    objects.extend(compile_cpp())
    objects.extend(assemble())

    link(objects)


def run_binary():
    build()
    run([binary], f"[RUN] {binary}")


def clean():
    if os.path.isdir(obj_dir):
        for root, _, files in os.walk(obj_dir):
            for file in files:
                os.remove(os.path.join(root, file))

    if os.path.exists(binary):
        os.remove(binary)

    print("[CLEAN]")


if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else "build"

    if command == "build":
        build()
    elif command == "run":
        run_binary()
    elif command == "clean":
        clean()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
