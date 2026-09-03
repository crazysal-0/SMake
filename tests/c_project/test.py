#!/usr/bin/env python3

import shutil
import subprocess
from pathlib import Path

TEST_DIR = Path(__file__).resolve().parent
ROOT_DIR = TEST_DIR.parent.parent
SMAKE = ROOT_DIR / "bin" / "smake"

APP = TEST_DIR / "app"
BUILD = TEST_DIR / "build"


def cleanup():
    if APP.is_dir():
        shutil.rmtree(APP)
    elif APP.exists():
        APP.unlink()

    if BUILD.exists():
        shutil.rmtree(BUILD)


cleanup()

result = subprocess.run(
    [str(SMAKE), "app"],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

# Executable should exist as a file.
if not APP.is_file():
    cleanup()
    exit(1)

# Object file should be inside build/app/.
if not (BUILD / "app" / "main.o").is_file():
    cleanup()
    exit(1)

# Run executable.
result = subprocess.run(
    [str(APP)],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

if result.stdout.strip() != "Hello from SMake!":
    cleanup()
    exit(1)

cleanup()
exit(0)