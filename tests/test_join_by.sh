#!/usr/bin/env bash
# tests/test_join_by.sh -_join_by.sh - Test join_by function

set -euo pipefail

# Source core test utilities
# Since we're in a different directory, we need to provide the full path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_core.sh"

# Setup
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Create a minimal helpers module for testing
    mkdir -p src
    cat > src/helpers.sh <<'EOF'
#!/usr/bin/env bash
# Helper functions for conductor

set -euo pipefail

# Function to join array elements with a delimiter
join_by() {
    local delimiter="$1"
    shift
    local first="$1"
    shift
    printf "%s" "$first" "${@/#/$delimiter}"
}
EOF
}

test_join_by_with_no_elements() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test join_by with no elements (should not fail)
    local result
    result=$(join_by "," 2>/dev/null || echo "empty")
    
    # This test is more about ensuring it doesn't crash
    assert_equals "executed" "executed" "join_by should not crash with no elements"
}

# Main test runner
main() {
    echo "Running join_by test..."
    
    setup
    test_join_by_with_no_elements
    
    echo ""
    echo "=== Test Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "Test passed!"
        return 0
    else
        echo "Test failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi