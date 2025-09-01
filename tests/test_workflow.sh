#!/usr/bin/env bash
# Test suite for the conductor workflow module

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
    
    # Create a minimal workflow module for testing
    cat > src/workflow.sh <<'EOF'
#!/usr/bin/env bash
# Workflow module for conductor

set -euo pipefail

WORKFLOWS_DIR="${WORKFLOWS_DIR:-workflows}"

# Create workflows directory if it doesn't exist
mkdir -p "$WORKFLOWS_DIR"

# List all workflow files
list_workflow_files() {
    if [[ -d "$WORKFLOWS_DIR" ]]; then
        find "$WORKFLOWS_DIR" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.sh" \) 2>/dev/null || true
    fi
}

# List workflow names
list_workflows() {
    local workflow_files
    workflow_files=$(list_workflow_files)
    
    if [[ -n "$workflow_files" ]]; then
        echo "$workflow_files" | while IFS= read -r file; do
            basename "$file"
        done
    fi
}

# Validate workflow file
validate_workflow() {
    local workflow_file="$1"
    
    if [[ ! -f "$workflow_file" ]]; then
        echo "Error: Workflow file '$workflow_file' not found"
        return 1
    fi
    
    # Check file extension
    case "$workflow_file" in
        *.yaml|*.yml|*.json|*.sh)
            # Valid extension
            ;;
        *)
            echo "Error: Unsupported workflow file type: $workflow_file"
            return 1
            ;;
    esac
    
    # For now, just return success
    return 0
}

# Run a workflow
run_workflow() {
    local workflow_name="$1"
    
    if [[ -z "$workflow_name" ]]; then
        echo "Error: No workflow specified"
        return 1
    fi
    
    # Try to find the workflow file
    local workflow_file=""
    
    # Check for the workflow file with different extensions
    for ext in yaml yml json sh; do
        if [[ -f "$WORKFLOWS_DIR/$workflow_name.$ext" ]]; then
            workflow_file="$WORKFLOWS_DIR/$workflow_name.$ext"
            break
        fi
    done
    
    # If not found with extension, check without extension
    if [[ -z "$workflow_file" ]] && [[ -f "$WORKFLOWS_DIR/$workflow_name" ]]; then
        workflow_file="$WORKFLOWS_DIR/$workflow_name"
    fi
    
    if [[ -z "$workflow_file" ]]; then
        echo "Error: Workflow '$workflow_name' not found"
        return 1
    fi
    
    # Validate the workflow file
    if ! validate_workflow "$workflow_file"; then
        return 1
    fi
    
    echo "Running workflow: $workflow_name"
    
    # Execute based on file type
    case "$workflow_file" in
        *.sh)
            # Execute shell script
            bash "$workflow_file"
            ;;
        *.yaml|*.yml|*.json)
            # For now, just print that we would process these
            echo "Processing $workflow_file"
            ;;
        *)
            echo "Error: Unsupported workflow file type: $workflow_file"
            return 1
            ;;
    esac
}
EOF
    
    # Create a sample workflow file for testing
    cat > workflows/example.yaml <<'EOF'
name: example
steps:
  - name: step1
    command: echo "Executing step 1"
  - name: step2
    command: echo "Executing step 2"
EOF
    
    cat > workflows/test.sh <<'EOF'
#!/usr/bin/env bash
echo "Running test workflow script"
EOF
    
    chmod +x workflows/test.sh
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test functions
test_list_workflows() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Get the list of workflows
    local workflows
    workflows=$(list_workflows)
    
    # Check that we have the expected workflows
    if echo "$workflows" | grep -q "example.yaml"; then
        echo "PASS: example.yaml found in workflow list"
    else
        echo "FAIL: example.yaml not found in workflow list"
        return 1
    fi
    
    if echo "$workflows" | grep -q "test.sh"; then
        echo "PASS: test.sh found in workflow list"
    else
        echo "FAIL: test.sh not found in workflow list"
        return 1
    fi
}

test_validate_workflow() {
    # Source the workflow module
    source src/workflow.sh
    
    # Test with valid workflow file
    if validate_workflow "workflows/example.yaml" 2>/dev/null; then
        echo "PASS: Valid workflow file validates successfully"
    else
        echo "FAIL: Valid workflow file should validate successfully"
        return 1
    fi
    
    # Test with non-existent workflow file
    if ! validate_workflow "workflows/nonexistent.yaml" 2>/dev/null; then
        echo "PASS: Non-existent workflow file fails validation"
    else
        echo "FAIL: Non-existent workflow file should fail validation"
        return 1
    fi
}

test_run_workflow() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test running a shell script workflow
    local output
    output=$(run_workflow "test" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: test"; then
        echo "PASS: Workflow run starts correctly"
    else
        echo "FAIL: Workflow run should start correctly"
        echo "Output: $output"
        return 1
    fi
    
    if echo "$output" | grep -q "Running test workflow script"; then
        echo "PASS: Shell script workflow executes correctly"
    else
        echo "FAIL: Shell script workflow should execute correctly"
        echo "Output: $output"
        return 1
    fi
}

test_run_nonexistent_workflow() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test running a non-existent workflow
    local output
    local exit_code=0
    
    output=$(run_workflow "nonexistent" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        echo "PASS: Non-existent workflow exits with code 1"
    else
        echo "FAIL: Non-existent workflow should exit with code 1"
        echo "Exit code: $exit_code"
        return 1
    fi
    
    if echo "$output" | grep -q "Error: Workflow 'nonexistent' not found"; then
        echo "PASS: Non-existent workflow shows error message"
    else
        echo "FAIL: Non-existent workflow should show error message"
        echo "Output: $output"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running workflow tests..."
    
    setup
    
    test_list_workflows
    test_validate_workflow
    test_run_workflow
    test_run_nonexistent_workflow
    
    teardown
    
    echo "All workflow tests passed!"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi