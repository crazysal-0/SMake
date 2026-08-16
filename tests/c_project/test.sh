#!/bin/bash

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
SMake="$ROOT_DIR/bin/smake"

cd "$TEST_DIR" || exit 1

rm -f app main.o hello.o

"$SMake" app > /dev/null 2>&1

if [ $? -ne 0 ]; then
    exit 1
fi

if [ ! -f app ]; then
    exit 1
fi

output=$(./app)

if [ "$output" = "Hello from SMake!" ]; then
    rm -f app main.o hello.o
    exit 0
fi

rm -f app main.o hello.o
exit 1