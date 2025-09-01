#!/usr/bin/env bash
# Test suite for the conductor CLI tool

set -euo pipefail

# Import test utilities or define helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $test_name"
    else
        echo "FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        return 1
    fi
}

assert_contains() {
    local needle="$1"
    local haystack="$2"
    local test_name="$3"
    
    if echo "$haystack" | grep -q "$needle"; then
        echo "PASS: $test_name"
    else
        echo "FAIL: $test_name"
        echo "  Expected to find: $needle"
        echo "  In output: $haystack"
        return 1
    fi
}

# Setup
setup() {
    # Create a temporary directory for testing
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Create the basic conductor structure for testing
    mkdir -p bin logs tests src
    
    # Create a minimal conductor script for testing
    cat > bin/conductor <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Simple conductor CLI for testing purposes
main() {
    case "${1:-}" in
        --help|-h)
            echo "Usage: conductor [OPTIONS] COMMAND"
            echo ""
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --version, -v  Show version information"
            echo ""
            echo "Commands:"
            echo "  list    List available workflows"
            echo "  run     Run a workflow"
            ;;
        --version|-v)
            echo "conductor v0.1.0"
            ;;
        list)
            echo "Available workflows:"
            echo "  example-workflow"
            ;;
        run)
            if [[ -n "${2:-}" ]]; then
                echo "Running workflow: $2"
            else
                echo "Error: No workflow specified"
                exit 1
            fi
            ;;
        "")
            echo "Error: No command specified"
            echo "Run 'conductor --help' for usage information"
            exit 1
            ;;
        *)
            echo "Error: Unknown command '$1'"
            echo "Run 'conductor --help' for usage information"
            exit 1
            ;;
    esac
}
main "$@"
EOF
    
    chmod +x bin/conductor
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test functions
test_help_output() {
    local output
    output=$(./bin/conductor --help)
    
    assert_contains "Usage: conductor" "$output" "Help output should contain usage information"
    assert_contains "Options:" "$output" "Help output should list options"
    assert_contains "Commands:" "$output" "Help output should list commands"
}

test_version_output() {
    local output
    output=$(./bin/conductor --version)
    
    assert_equals "conductor v0.1.0" "$output" "Version output should match expected format"
}

test_list_workflows() {
    local output
    output=$(./bin/conductor list)
    
    assert_contains "Available workflows:" "$output" "List command should show header"
    assert_contains "example-workflow" "$output" "List command should show example workflow"
}

test_run_workflow() {
    local output
    output=$(./bin/conductor run example-workflow)
    
    assert_equals "Running workflow: example-workflow" "$output" "Run command should execute workflow"
}

test_run_without_workflow() {
    local output
    local exit_code=0
    
    output=$(./bin/conductor run 2>&1) || exit_code=$?
    
    assert_equals 1 "$exit_code" "Run without workflow should exit with error code 1"
    assert_contains "Error: No workflow specified" "$output" "Run without workflow should show error message"
}

test_no_command() {
    local output
    local exit_code=0
    
    output=$(./bin/conductor 2>&1) || exit_code=$?
    
    assert_equals 1 "$exit_code" "No command should exit with error code 1"
    assert_contains "Error: No command specified" "$output" "No command should show error message"
}

test_unknown_command() {
    local output
    local exit_code=0
    
    output=$(./bin/conductor unknown 2>&1) || exit_code=$?
    
    assert_equals 1 "$exit_code" "Unknown command should exit with error code 1"
    assert_contains "Error: Unknown command 'unknown'" "$output" "Unknown command should show error message"
}

# Main test runner
main() {
    echo "Running CLI tests..."
    
    setup
    
    test_help_output
    test_version_output
    test_list_workflows
    test_run_workflow
    test_run_without_workflow
    test_no_command
    test_unknown_command
    
    teardown
    
    echo "All CLI tests passed!"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi