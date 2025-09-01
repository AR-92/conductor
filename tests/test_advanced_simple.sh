#!/usr/bin/env bash
# tests/test_advanced_simple.sh - Simple advanced workflow tests

set -euo pipefail

# Source core test utilities
source "$(dirname "${BASH_SOURCE[0]}")/test_core.sh"

# Test functions
test_function_declaration() {
    # Define a simple function
    dummy_function() {
        echo "dummy"
    }
    
    # Check that function exists
    if declare -f dummy_function >/dev/null 2>&1; then
        assert_equals "exists" "exists" "Function should be declared"
    else
        assert_equals "exists" "missing" "Function should be declared"
        return 1
    fi
}

test_multiple_function_declarations() {
    # Define multiple functions
    func1() { echo "func1"; }
    func2() { echo "func2"; }
    func3() { echo "func3"; }
    
    # Check that all functions exist
    local count=0
    
    if declare -f func1 >/dev/null 2>&1; then
        count=$((count + 1))
    fi
    
    if declare -f func2 >/dev/null 2>&1; then
        count=$((count + 1))
    fi
    
    if declare -f func3 >/dev/null 2>&1; then
        count=$((count + 1))
    fi
    
    if [[ $count -eq 3 ]]; then
        assert_equals "3" "3" "All functions should be declared"
    else
        assert_equals "3" "$count" "All functions should be declared"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running simple advanced workflow tests..."
    
    test_function_declaration
    test_multiple_function_declarations
    
    echo ""
    echo "=== Simple Advanced Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All simple advanced tests passed!"
        return 0
    else
        echo "Some simple advanced tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi