# SMake

**Simple Make - A simple TOML-based build system.**

SMake is a simple open-source TOML-based make alternative written in D, mainly used for C, C++, and Assembly.

## Why it Exists

Make is a very good build system, but it's a Turing-complete interpreter. If you would rather use something more simple and readable, **SMake** is for you because TOML is very simple and readable, compared to Bash, which Make is very similar to.

## Syntax

In SMake, there are two main sections of the `SMake.toml`: `languages` and `targets`. They are both extremely simple.

Languages have 2 fields: `compiler` and `flags`. The compiler is the first part of the command which compiles the files, and the flags are the second part, which are the flags for the compiler. The section name is important as well because it defines the file extension that uses the compiler and the flags in the section.

```toml
[languages.c]
compiler = "cc"
flags = ["-Wall", "-Wextra", "-c"]
```

Targets have 3 fields: `sources`, `output`, and `linker`. `sources` are just the source files, `output` is the path to where you want your executable to be, and `linker` is the linker you're using to link all of the source files together.

```toml
[targets.app]
sources = ["main.c", "hello.asm"]
output = "app"
linker = "cc"
```

A full `SMake.toml` would be:

```toml
[languages.c]
compiler = "cc"
flags = ["-Wall", "-Wextra", "-c"]

[languages.asm]
compiler = "nasm"
flags = ["-f", "elf64"]

[targets.app]
sources = ["main.c", "hello.asm"]
output = "app"
linker = "cc"
```

## CLI

`smake <target>`: builds a specific target defined in your `SMake.toml` file.

`smake all`: builds all of the targets.

`smake clean`: removes the temporary stuff like the object file and the executable.

`smake --help`: shows a help message similar to this one.

`smake --version`: shows the version of SMake you have.

## Install

Clone the repository and use DUB to build it. Don't worry, though, because this will get put on APT soon.

## License

This project uses the MIT license. Look at `LICENSE` for more details.
