#!/usr/bin/env bash
# Helper functions for conductor

set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a directory is writable
is_writable() {
    [[ -w "$1" ]] 2>/dev/null
}

# Function to get the absolute path of a file
get_absolute_path() {
    local relative_path="$1"
    realpath "$relative_path" 2>/dev/null || echo "$relative_path"
}

# Function to create a directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# Function to check if a file is empty
is_empty() {
    [[ ! -s "$1" ]]
}

# Function to join array elements with a delimiter
join_by() {
    local delimiter="$1"
    shift
    local first="$1"
    shift
    printf "%s" "$first" "${@/#/$delimiter}"
}