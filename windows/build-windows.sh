#!/usr/bin/env bash
# Cross-compiles CoreTheory.scr with MinGW-w64 (Ubuntu: apt install gcc-mingw-w64-x86-64).
set -euo pipefail
cd "$(dirname "$0")/src"
x86_64-w64-mingw32-windres coretheory.rc -O coff -o coretheory.res
x86_64-w64-mingw32-gcc -O2 -s -municode -mwindows -static -Wall -Wextra \
  coretheory_scr.c coretheory.res -o ../CoreTheory.scr -lshell32 -ladvapi32 -luser32
rm -f coretheory.res
echo "Built windows/CoreTheory.scr"
