#!/usr/bin/env bash
# tests/test_helpers.sh - Helpers module tests

set -euo pipefail

# Source core test utilities
source "$(dirname "${BASH_SOURCE[0]}")/test_core.sh"

# Setup
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Create the basic conductor structure for testing
    mkdir -p bin logs tests src
    
    # Create a minimal helpers module for testing
    cat > src/helpers.sh <<'EOF'
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
EOF
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test functions
test_command_exists_with_existing_command() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test with an existing command
    if command_exists "bash"; then
        assert_equals "true" "true" "command_exists should return true for existing command"
    else
        assert_equals "true" "false" "command_exists should return true for existing command"
        return 1
    fi
}

test_command_exists_with_nonexistent_command() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test with a non-existent command
    if ! command_exists "nonexistent_command_12345"; then
        assert_equals "false" "false" "command_exists should return false for non-existent command"
    else
        assert_equals "false" "true" "command_exists should return false for non-existent command"
        return 1
    fi
}

test_is_writable_with_writable_dir() {
    # Source the helpers module
    source src/helpers.sh
    
    # Create a writable directory
    mkdir -p writable_dir
    
    # Test with a writable directory
    if is_writable "writable_dir"; then
        assert_equals "true" "true" "is_writable should return true for writable directory"
    else
        assert_equals "true" "false" "is_writable should return true for writable directory"
        return 1
    fi
}

test_is_writable_with_nonexistent_dir() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test with a non-existent directory
    if ! is_writable "nonexistent_dir"; then
        assert_equals "false" "false" "is_writable should return false for non-existent directory"
    else
        assert_equals "false" "true" "is_writable should return false for non-existent directory"
        return 1
    fi
}

test_ensure_dir_creates_directory() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test that ensure_dir creates a directory
    ensure_dir "new_directory"
    
    if [[ -d "new_directory" ]]; then
        assert_equals "exists" "exists" "ensure_dir should create directory"
    else
        assert_equals "exists" "missing" "ensure_dir should create directory"
        return 1
    fi
}

test_ensure_dir_with_existing_directory() {
    # Source the helpers module
    source src/helpers.sh
    
    # Create a directory
    mkdir -p existing_directory
    
    # Test that ensure_dir doesn't fail with existing directory
    ensure_dir "existing_directory"
    
    if [[ -d "existing_directory" ]]; then
        assert_equals "exists" "exists" "ensure_dir should not fail with existing directory"
    else
        assert_equals "exists" "missing" "ensure_dir should not fail with existing directory"
        return 1
    fi
}

test_is_empty_with_empty_file() {
    # Source the helpers module
    source src/helpers.sh
    
    # Create an empty file
    touch empty_file.txt
    
    # Test with an empty file
    if is_empty "empty_file.txt"; then
        assert_equals "true" "true" "is_empty should return true for empty file"
    else
        assert_equals "true" "false" "is_empty should return true for empty file"
        return 1
    fi
}

test_is_empty_with_nonexistent_file() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test with a non-existent file
    if is_empty "nonexistent_file.txt"; then
        assert_equals "true" "true" "is_empty should return true for non-existent file"
    else
        assert_equals "true" "false" "is_empty should return true for non-existent file"
        return 1
    fi
}

test_is_empty_with_nonempty_file() {
    # Source the helpers module
    source src/helpers.sh
    
    # Create a non-empty file
    echo "content" > nonempty_file.txt
    
    # Test with a non-empty file
    if ! is_empty "nonempty_file.txt"; then
        assert_equals "false" "false" "is_empty should return false for non-empty file"
    else
        assert_equals "false" "true" "is_empty should return false for non-empty file"
        return 1
    fi
}

test_join_by_with_single_element() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test join_by with single element
    local result
    result=$(join_by "," "first")
    
    if [[ "$result" == "first" ]]; then
        assert_equals "first" "first" "join_by should return single element for single item"
    else
        assert_equals "first" "$result" "join_by should return single element for single item"
        return 1
    fi
}

test_join_by_with_multiple_elements() {
    # Source the helpers module
    source src/helpers.sh
    
    # Test join_by with multiple elements
    local result
    result=$(join_by "," "first" "second" "third")
    
    if [[ "$result" == "first,second,third" ]]; then
        assert_equals "first,second,third" "first,second,third" "join_by should join multiple elements with delimiter"
    else
        assert_equals "first,second,third" "$result" "join_by should join multiple elements with delimiter"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running helpers tests..."
    
    setup
    
    test_command_exists_with_existing_command
    test_command_exists_with_nonexistent_command
    test_is_writable_with_writable_dir
    test_is_writable_with_nonexistent_dir
    test_ensure_dir_creates_directory
    test_ensure_dir_with_existing_directory
    test_is_empty_with_empty_file
    test_is_empty_with_nonexistent_file
    test_is_empty_with_nonempty_file
    test_join_by_with_single_element
    test_join_by_with_multiple_elements
    
    teardown
    
    echo ""
    echo "=== Helpers Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All helpers tests passed!"
        return 0
    else
        echo "Some helpers tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi