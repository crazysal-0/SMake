#!/usr/bin/env python3

import shutil
import subprocess
from pathlib import Path

TEST_DIR = Path(__file__).resolve().parent
ROOT_DIR = TEST_DIR.parent.parent
SMAKE = ROOT_DIR / "bin" / "smake"

APP = TEST_DIR / "app"
BUILD = TEST_DIR / "build"
OBJECT_DIR = BUILD / "app"


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

# Final executable must be output directly as "app".
if not APP.is_file():
    cleanup()
    exit(1)

# Object directory must be build/app/.
if not OBJECT_DIR.is_dir():
    cleanup()
    exit(1)

# main.o must be inside build/app/.
if not (OBJECT_DIR / "main.o").is_file():
    cleanup()
    exit(1)

# The object must NOT be beside the executable.
if (TEST_DIR / "main.o").exists():
    cleanup()
    exit(1)

cleanup()
exit(0)