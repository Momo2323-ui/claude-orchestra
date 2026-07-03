#!/usr/bin/env bash
# build-skill-index.sh — Thin wrapper that delegates to build-skill-index.py
# Keeps the callable interface as a .sh file for hook/intake compatibility.
exec python3 "$(dirname "$0")/build-skill-index.py" "$@"
