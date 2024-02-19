#!/usr/bin/env bash
#######################################
# Examen NASM build for Mac.
# (Nasm must be installed and in the PATH)
#######################################
set -Cue

#######################################
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "${THIS_DIR}/../.." && pwd)"
BIN_DIR="${ROOT_DIR}/bin"

#######################################
# Invoke nasm to generate program image:
cd "${THIS_DIR}" && \
    nasm exam.asm -f bin -o "${BIN_DIR}/exam.com"
