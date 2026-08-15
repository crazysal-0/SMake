#!/bin/bash

cd "$(dirname "$0")"

../../bin/smake > /dev/null 2>&1

if [ $? -eq 1 ]; then
    exit 0
fi

exit 1