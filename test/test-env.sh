#!/bin/bash
# Smoke test: verifies the devcontainer environment has all required tools.
# Run inside the built container. Exit code 0 = pass, non-zero = fail.
set -euo pipefail

PASS=0
FAIL=0

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" > /dev/null 2>&1; then
        echo "PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $label"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== PLCC environment smoke test ==="

check "plccmk is on PATH"  "command -v plccmk"
check "scan is on PATH"    "command -v scan"
check "parse is on PATH"   "command -v parse"
check "rep is on PATH"     "command -v rep"
check "Java 17+ present"   "java --version 2>&1 | grep -qE '^(openjdk|java) (17|2[0-9])'"
check "Python 3.9+ present" "python3 --version 2>&1 | grep -qE '3\.(9|1[0-9])'"
check "git present"        "command -v git"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
