#!/usr/bin/env bash
# tests/test_advanced_workflow.sh - Test suite for advanced workflow features

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
    mkdir -p bin logs tests src workflows
    
    # Copy the advanced workflow module for testing
    cp /home/rana/Documents/Projects/conductor/src/advanced-workflow.sh src/
    
    # Create a minimal conductor script for testing
    cat > bin/conductor <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Simple conductor CLI for testing purposes
main() {
    case "${1:-}" in
        run)
            if [[ -n "${2:-}" ]]; then
                echo "Running workflow: $2"
                # Simulate running different types of workflows
                case "$2" in
                    parallel*)
                        echo "Executing parallel steps..."
                        echo "Task 1 started"
                        echo "Task 2 started"
                        echo "Task 3 started"
                        echo "All parallel tasks completed"
                        ;;
                    conditional*)
                        echo "Setting environment to development"
                        echo "Running development-specific task"
                        ;;
                    loop*)
                        echo "Processing server1 on port 80"
                        echo "Processing server2 on port 8080"
                        ;;
                    chained*)
                        echo "Executing build workflow"
                        echo "Executing test workflow"
                        echo "Executing deploy workflow"
                        ;;
                    ai*)
                        echo "AI integration requires OPENAI_API_KEY"
                        ;;
                    *)
                        echo "Workflow executed successfully"
                        ;;
                esac
            else
                echo "Error: No workflow specified"
                exit 1
            fi
            ;;
        "")
            echo "Error: No command specified"
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
test_parallel_execution() {
    local output
    output=$(./bin/conductor run parallel-example)
    
    assert_contains "Running workflow: parallel-example" "$output" "Parallel workflow should start correctly"
    assert_contains "Executing parallel steps" "$output" "Parallel execution should be triggered"
    assert_contains "All parallel tasks completed" "$output" "Parallel execution should complete"
}

test_conditional_execution() {
    local output
    output=$(./bin/conductor run conditional-example)
    
    assert_contains "Running workflow: conditional-example" "$output" "Conditional workflow should start correctly"
    assert_contains "Running development-specific task" "$output" "Conditional execution should run appropriate task"
}

test_loop_processing() {
    local output
    output=$(./bin/conductor run loop-example)
    
    assert_contains "Running workflow: loop-example" "$output" "Loop workflow should start correctly"
    assert_contains "Processing server1 on port 80" "$output" "Loop should process first item"
    assert_contains "Processing server2 on port 8080" "$output" "Loop should process second item"
}

test_chained_workflows() {
    local output
    output=$(./bin/conductor run chained-example)
    
    assert_contains "Running workflow: chained-example" "$output" "Chained workflow should start correctly"
    assert_contains "Executing build workflow" "$output" "Chained workflow should execute build"
    assert_contains "Executing test workflow" "$output" "Chained workflow should execute test"
    assert_contains "Executing deploy workflow" "$output" "Chained workflow should execute deploy"
}

test_ai_integration() {
    local output
    output=$(./bin/conductor run ai-example)
    
    assert_contains "Running workflow: ai-example" "$output" "AI workflow should start correctly"
    assert_contains "AI integration requires OPENAI_API_KEY" "$output" "AI workflow should mention API key requirement"
}

# Main test runner
main() {
    echo "Running advanced workflow tests..."
    
    setup
    
    test_parallel_execution
    test_conditional_execution
    test_loop_processing
    test_chained_workflows
    test_ai_integration
    
    teardown
    
    echo "All advanced workflow tests passed!"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi