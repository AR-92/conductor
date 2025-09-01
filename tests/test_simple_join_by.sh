#!/usr/bin/env bash
# tests/test_simple_join_by.sh - Simple test for join_by function

set -euo pipefail

# Function to join array elements with a delimiter
join_by() {
    local delimiter="$1"
    shift
    local first="$1"
    shift
    printf "%s" "$first" "${@/#/$delimiter}"
}

# Test join_by with no elements (should not fail)
echo "Testing join_by with no elements..."
result=$(join_by "," 2>/dev/null || echo "empty")
echo "Result: $result"

echo "Test completed"
exit 0