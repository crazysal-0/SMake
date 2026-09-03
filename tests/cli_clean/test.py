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

# Build first.
result = subprocess.run(
    [str(SMAKE), "app"],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

# Verify build happened.
if not APP.is_file():
    cleanup()
    exit(1)

if not (BUILD / "app" / "main.o").is_file():
    cleanup()
    exit(1)

# Clean.
result = subprocess.run(
    [str(SMAKE), "clean"],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

# Executable should be gone.
if APP.exists():
    cleanup()
    exit(1)

# Object directory should be gone.
if (BUILD / "app").exists():
    cleanup()
    exit(1)

cleanup()
exit(0)