#!/bin/bash

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
SMake="$ROOT_DIR/bin/smake"

cd "$TEST_DIR" || exit 1

rm -f app main.o

"$SMake" app > /dev/null 2>&1

if [ $? -ne 0 ]; then
    exit 1
fi

if [ ! -f app ] || [ ! -f main.o ]; then
    rm -f app main.o
    exit 1
fi

"$SMake" clean > /dev/null 2>&1

if [ $? -ne 0 ]; then
    exit 1
fi

if [ -f app ] || [ -f main.o ]; then
    exit 1
fi

exit 0