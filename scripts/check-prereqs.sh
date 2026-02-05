#!/usr/bin/env bash
# Check prerequisites for AWMP verification kernel

set -e

echo "Checking AWMP prerequisites..."
echo ""

errors=0

check_cmd() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -1)
        echo "✓ $name: $version"
    else
        echo "✗ $name: NOT FOUND"
        errors=$((errors + 1))
    fi
}

check_cmd bash "bash"
check_cmd make "make"
check_cmd rg "rg (ripgrep)"
check_cmd jq "jq"
check_cmd sha256sum "sha256sum"
check_cmd git "git"

echo ""

if [ $errors -eq 0 ]; then
    echo "All prerequisites satisfied."
    exit 0
else
    echo "$errors prerequisite(s) missing. See PREREQUISITES.md for installation instructions."
    exit 1
fi
