#!/bin/bash

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/../.." && pwd)"
SMake="$ROOT_DIR/bin/smake"

"$SMake" --help > /dev/null 2>&1

if [ $? -eq 0 ]; then
    exit 0
fi

exit 1