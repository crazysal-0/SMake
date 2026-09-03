#!/usr/bin/env python3

import subprocess
from pathlib import Path

GREEN = "\033[32m"
RED = "\033[31m"
RESET = "\033[0m"

TEST_DIR = Path(__file__).resolve().parent

passed = 0
failed = 0

print("Running SMake tests...")
print()

for test_dir in sorted(TEST_DIR.iterdir()):
    if not test_dir.is_dir():
        continue

    test_sh = test_dir / "test.sh"
    test_py = test_dir / "test.py"

    if test_sh.exists():
        command = ["bash", str(test_sh)]
    elif test_py.exists():
        command = ["python3", str(test_py)]
    else:
        continue

    result = subprocess.run(command)

    if result.returncode == 0:
        print(f"{GREEN}PASS{RESET} {test_dir.name}")
        passed += 1
    else:
        print(f"{RED}FAIL{RESET} {test_dir.name}")
        failed += 1

print()
print(f"Passed: {passed}")
print(f"Failed: {failed}")

if failed != 0:
    exit(1)

print(f"\n{GREEN}All tests passed!{RESET}")
exit(0)