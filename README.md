# SMake

SMake is a simple build tool for C, C++, and Assembly projects. I just made it cause I didnt want to use CMake for my compiler, and Make is too old and doenst have good modern features.

## Install

### Using pipx

```bash
pipx install smake-build
```

### Using pip

```bash
pip install smake-build --user --break-system-packages
```

## Commands

Build the project:

```bash
smake build
```

Run the project:

```bash
smake run
```

Clean object files and binaries:

```bash
smake clean
```

## Example Project

```text
project/
├── SMake.toml
├── inc/
├── src/
└── bin/
```

## Example SMake.toml

```toml
[output]
binary = "bin/app"
object_dir = "obj"

[c]
compiler = "gcc"
source_files = ["src/**/*.c"]
flags = ["-O2", "-Wall"]

[cpp]
compiler = "g++"
source_files = ["src/**/*.cpp"]
flags = ["-std=c++20", "-O2", "-Wall"]

[asm]
assembler = "nasm"
source_files = ["src/**/*.asm"]
flags = ["-felf64"]

[link]
linker = "g++"
flags = []
```

## License

SMake is licensed under the BSD 3-Clause License.

See the LICENSE file for details.
