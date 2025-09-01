#!/usr/bin/env bash
# tests/test_core.sh - Core functionality tests

set -euo pipefail

# Test counter
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test utilities
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_contains() {
    local needle="$1"
    local haystack="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if echo "$haystack" | grep -q "$needle"; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected to find: $needle"
        echo "  In output: $haystack"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_not_contains() {
    local needle="$1"
    local haystack="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if ! echo "$haystack" | grep -q "$needle"; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected NOT to find: $needle"
        echo "  In output: $haystack"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_exit_code() {
    local expected_code="$1"
    local command="$2"
    local test_name="$3"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    local exit_code=0
    eval "$command" >/dev/null 2>&1 || exit_code=$?
    
    if [[ $exit_code -eq $expected_code ]]; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected exit code: $expected_code"
        echo "  Actual exit code: $exit_code"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [[ -f "$file" ]]; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected file to exist: $file"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local test_name="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [[ -d "$dir" ]]; then
        echo "PASS: $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL: $test_name"
        echo "  Expected directory to exist: $dir"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi
}

# Test suite functions
test_core_utilities() {
    echo "=== Core Utilities Tests ==="
    
    # Test assert_equals
    assert_equals "test" "test" "assert_equals should pass for equal values"
    assert_equals "1" "1" "assert_equals should pass for equal numbers"
    
    # Test assert_contains
    assert_contains "hello" "hello world" "assert_contains should find substring"
    assert_contains "test" "this is a test string" "assert_contains should find word in string"
    
    # Test assert_not_contains
    assert_not_contains "xyz" "hello world" "assert_not_contains should not find missing substring"
    
    # Test assert_exit_code
    assert_exit_code 0 "true" "assert_exit_code should pass for successful command"
    assert_exit_code 1 "false" "assert_exit_code should pass for failing command"
    
    # Test assert_file_exists
    assert_file_exists "/etc/passwd" "assert_file_exists should find existing file"
    
    # Test assert_dir_exists
    assert_dir_exists "/tmp" "assert_dir_exists should find existing directory"
}

# Main test runner
main() {
    echo "Running core utilities tests..."
    
    test_core_utilities
    
    echo ""
    echo "=== Test Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All core utilities tests passed!"
        return 0
    else
        echo "Some tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi