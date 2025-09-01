#!/usr/bin/env bash
# tests/test_debug_join_by.sh - Debug test for join_by function

set -euo pipefail

# Function to join array elements with a delimiter
join_by() {
    echo "Called with $# arguments: $*"
    local delimiter="$1"
    echo "Delimiter: $delimiter"
    shift
    echo "After shift, $# arguments: $*"
    local first="$1"
    echo "First: $first"
    shift
    echo "After second shift, $# arguments: $*"
    printf "%s" "$first" "${@/#/$delimiter}"
}

# Test join_by with no elements (should not fail)
echo "Testing join_by with no elements..."
set +e  # Disable exit on error
result=$(join_by "," 2>&1)
exit_code=$?
set -e  # Re-enable exit on error
echo "Exit code: $exit_code"
echo "Result: $result"

echo "Test completed"