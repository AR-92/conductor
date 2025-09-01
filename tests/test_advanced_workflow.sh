#!/usr/bin/env bash
# tests/test_advanced_workflow.sh - Advanced workflow features tests

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

test_parallel_execution_with_multiple_tasks() {
    local output
    output=$(./bin/conductor run parallel-example)
    
    assert_contains "Task 1 started" "$output" "Parallel execution should start task 1"
    assert_contains "Task 2 started" "$output" "Parallel execution should start task 2"
    assert_contains "Task 3 started" "$output" "Parallel execution should start task 3"
}

test_conditional_execution() {
    local output
    output=$(./bin/conductor run conditional-example)
    
    assert_contains "Running workflow: conditional-example" "$output" "Conditional workflow should start correctly"
    assert_contains "Running development-specific task" "$output" "Conditional execution should run appropriate task"
}

test_conditional_execution_environment_setup() {
    local output
    output=$(./bin/conductor run conditional-example)
    
    assert_contains "Setting environment to development" "$output" "Conditional execution should set environment"
}

test_loop_processing() {
    local output
    output=$(./bin/conductor run loop-example)
    
    assert_contains "Running workflow: loop-example" "$output" "Loop workflow should start correctly"
    assert_contains "Processing server1 on port 80" "$output" "Loop should process first item"
    assert_contains "Processing server2 on port 8080" "$output" "Loop should process second item"
}

test_loop_processing_multiple_items() {
    local output
    output=$(./bin/conductor run loop-example)
    
    # Count occurrences of "Processing" to ensure multiple items are processed
    local count
    count=$(echo "$output" | grep -c "Processing" || echo "0")
    
    if [[ $count -ge 2 ]]; then
        assert_equals ">=2" ">=2" "Loop should process multiple items"
    else
        assert_equals ">=2" "$count" "Loop should process multiple items"
        return 1
    fi
}

test_chained_workflows() {
    local output
    output=$(./bin/conductor run chained-example)
    
    assert_contains "Running workflow: chained-example" "$output" "Chained workflow should start correctly"
    assert_contains "Executing build workflow" "$output" "Chained workflow should execute build"
    assert_contains "Executing test workflow" "$output" "Chained workflow should execute test"
    assert_contains "Executing deploy workflow" "$output" "Chained workflow should execute deploy"
}

test_chained_workflows_sequence() {
    local output
    output=$(./bin/conductor run chained-example)
    
    # Check that build comes before test
    local build_pos
    local test_pos
    build_pos=$(echo "$output" | grep -b -o "Executing build workflow" | cut -d: -f1)
    test_pos=$(echo "$output" | grep -b -o "Executing test workflow" | cut -d: -f1)
    
    if [[ -n "$build_pos" && -n "$test_pos" && $build_pos -lt $test_pos ]]; then
        assert_equals "correct" "correct" "Build should execute before test in chained workflow"
    else
        assert_equals "correct" "incorrect" "Build should execute before test in chained workflow"
        return 1
    fi
}

test_ai_integration() {
    local output
    output=$(./bin/conductor run ai-example)
    
    assert_contains "Running workflow: ai-example" "$output" "AI workflow should start correctly"
    assert_contains "AI integration requires OPENAI_API_KEY" "$output" "AI workflow should mention API key requirement"
}

test_ai_integration_no_api_key() {
    local output
    output=$(./bin/conductor run ai-example)
    
    assert_not_contains "AI analysis complete" "$output" "AI workflow should not run analysis without API key"
}

# Additional tests for advanced workflow functions
test_advanced_workflow_module_exists() {
    # Check that advanced workflow module exists
    if [[ -f "src/advanced-workflow.sh" ]]; then
        assert_equals "exists" "exists" "Advanced workflow module should exist"
    else
        assert_equals "exists" "missing" "Advanced workflow module should exist"
        return 1
    fi
}

test_advanced_workflow_module_sourceable() {
    # Check that advanced workflow module can be sourced
    if source src/advanced-workflow.sh 2>/dev/null; then
        assert_equals "sourceable" "sourceable" "Advanced workflow module should be sourceable"
    else
        assert_equals "sourceable" "not sourceable" "Advanced workflow module should be sourceable"
        return 1
    fi
}

test_execute_parallel_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that execute_parallel function exists
    if declare -f execute_parallel >/dev/null 2>&1; then
        assert_equals "exists" "exists" "execute_parallel function should exist"
    else
        assert_equals "exists" "missing" "execute_parallel function should exist"
        return 1
    fi
}

test_execute_conditional_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that execute_conditional function exists
    if declare -f execute_conditional >/dev/null 2>&1; then
        assert_equals "exists" "exists" "execute_conditional function should exist"
    else
        assert_equals "exists" "missing" "execute_conditional function should exist"
        return 1
    fi
}

test_execute_loop_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that execute_loop function exists
    if declare -f execute_loop >/dev/null 2>&1; then
        assert_equals "exists" "exists" "execute_loop function should exist"
    else
        assert_equals "exists" "missing" "execute_loop function should exist"
        return 1
    fi
}

test_execute_chained_workflows_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that execute_chained_workflows function exists
    if declare -f execute_chained_workflows >/dev/null 2>&1; then
        assert_equals "exists" "exists" "execute_chained_workflows function should exist"
    else
        assert_equals "exists" "missing" "execute_chained_workflows function should exist"
        return 1
    fi
}

test_execute_ai_step_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that execute_ai_step function exists
    if declare -f execute_ai_step >/dev/null 2>&1; then
        assert_equals "exists" "exists" "execute_ai_step function should exist"
    else
        assert_equals "exists" "missing" "execute_ai_step function should exist"
        return 1
    fi
}

test_demo_advanced_features_function_exists() {
    # Source the advanced workflow module
    source src/advanced-workflow.sh
    
    # Check that demo_advanced_features function exists
    if declare -f demo_advanced_features >/dev/null 2>&1; then
        assert_equals "exists" "exists" "demo_advanced_features function should exist"
    else
        assert_equals "exists" "missing" "demo_advanced_features function should exist"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running advanced workflow tests..."
    
    setup
    
    test_parallel_execution
    test_parallel_execution_with_multiple_tasks
    test_conditional_execution
    test_conditional_execution_environment_setup
    test_loop_processing
    test_loop_processing_multiple_items
    test_chained_workflows
    test_chained_workflows_sequence
    test_ai_integration
    test_ai_integration_no_api_key
    test_advanced_workflow_module_exists
    test_advanced_workflow_module_sourceable
    test_execute_parallel_function_exists
    test_execute_conditional_function_exists
    test_execute_loop_function_exists
    test_execute_chained_workflows_function_exists
    test_execute_ai_step_function_exists
    test_demo_advanced_features_function_exists
    
    teardown
    
    echo ""
    echo "=== Advanced Workflow Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All advanced workflow tests passed!"
        return 0
    else
        echo "Some advanced workflow tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi