#!/usr/bin/env bash
# tests/test_debug_advanced.sh - Debug advanced workflow tests

set -euo pipefail

# Source core test utilities
source "$(dirname "${BASH_SOURCE[0]}")/test_core.sh"

# Setup
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Create the basic conductor structure for testing
    mkdir -p bin logs tests src workflows
    
    # Copy the advanced workflow module for testing
    cp /home/rana/Documents/Projects/conductor/src/advanced-workflow.sh src/
}

# Test functions
test_advanced_workflow_module_sourceable() {
    echo "Starting test_advanced_workflow_module_sourceable"
    
    # Check that advanced workflow module can be sourced
    if source src/advanced-workflow.sh 2>/dev/null; then
        echo "Module sourced successfully"
        assert_equals "sourceable" "sourceable" "Advanced workflow module should be sourceable"
    else
        echo "Module failed to source"
        assert_equals "sourceable" "not sourceable" "Advanced workflow module should be sourceable"
        return 1
    fi
    
    echo "Finished test_advanced_workflow_module_sourceable"
}

# Main test runner
main() {
    echo "Running debug advanced workflow test..."
    
    setup
    test_advanced_workflow_module_sourceable
    
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