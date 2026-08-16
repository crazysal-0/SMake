#!/bin/bash

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
SMake="$ROOT_DIR/bin/smake"

cd "$TEST_DIR" || exit 1

rm -f app1 app2 main1.o main2.o

"$SMake" all > /dev/null 2>&1

if [ $? -ne 0 ]; then
    exit 1
fi

if [ ! -f app1 ] || [ ! -f app2 ]; then
    rm -f app1 app2 main1.o main2.o
    exit 1
fi

rm -f app1 app2 main1.o main2.o
exit 0