#!/bin/bash

GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

passed=0
failed=0

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"

run_test() {
    name="$1"
    shift

    if "$@"; then
        printf "${GREEN}PASS${RESET} %s\n" "$name"
        ((passed++))
    else
        printf "${RED}FAIL${RESET} %s\n" "$name"
        ((failed++))
    fi
}

echo "Running SMake tests..."
echo

for test_dir in "$TEST_DIR"/*/; do
    test_file="$test_dir/test.sh"

    if [ -f "$test_file" ]; then
        name="$(basename "$test_dir")"
        run_test "$name" bash "$test_file"
    fi
done

echo
echo "Passed: $passed"
echo "Failed: $failed"

if [ "$failed" -ne 0 ]; then
    exit 1
fi

printf "\n${GREEN}All tests passed!${RESET}\n"
exit 0