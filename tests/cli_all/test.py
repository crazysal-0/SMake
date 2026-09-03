#!/usr/bin/env python3

import shutil
import subprocess
from pathlib import Path

TEST_DIR = Path(__file__).resolve().parent
ROOT_DIR = TEST_DIR.parent.parent
SMAKE = ROOT_DIR / "bin" / "smake"

APP1 = TEST_DIR / "app1"
APP2 = TEST_DIR / "app2"
BUILD = TEST_DIR / "build"


def cleanup():
    for path in [APP1, APP2]:
        if path.is_dir():
            shutil.rmtree(path)
        elif path.exists():
            path.unlink()

    if BUILD.exists():
        shutil.rmtree(BUILD)


cleanup()

result = subprocess.run(
    [str(SMAKE), "all"],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

# Both executables should exist.
if not APP1.is_file():
    cleanup()
    exit(1)

if not APP2.is_file():
    cleanup()
    exit(1)

# Both targets should have their own object directories.
if not (BUILD / "app1" / "main1.o").is_file():
    cleanup()
    exit(1)

if not (BUILD / "app2" / "main2.o").is_file():
    cleanup()
    exit(1)

# Run app1.
result = subprocess.run(
    [str(APP1)],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

# Run app2.
result = subprocess.run(
    [str(APP2)],
    cwd=TEST_DIR,
    capture_output=True,
    text=True,
)

if result.returncode != 0:
    cleanup()
    exit(1)

cleanup()
exit(0)