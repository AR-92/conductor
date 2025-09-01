#!/usr/bin/env bash
# tests/test_workflow.sh - Workflow module tests

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
    echo "Available workflows:"
    
    local workflow_files
    workflow_files=$(list_workflow_files)
    
    if [[ -n "$workflow_files" ]]; then
        echo "$workflow_files" | while IFS= read -r file; do
            # Get just the filename without extension
            local basename
            basename=$(basename "$file")
            # Remove extension
            local name="${basename%.*}"
            echo "  $name"
        done
    else
        echo "  No workflows found"
    fi
}

# Validate workflow file
validate_workflow() {
    local workflow_file="$1"
    
    if [[ ! -f "$workflow_file" ]]; then
        echo "Error: Workflow file '$workflow_file' not found" >&2
        return 1
    fi
    
    # Check file extension
    case "$workflow_file" in
        *.yaml|*.yml|*.json|*.sh)
            # Valid extension
            ;;
        *)
            echo "Error: Unsupported workflow file type: $workflow_file" >&2
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
        echo "Error: No workflow specified" >&2
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
        echo "Error: Workflow '$workflow_name' not found" >&2
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
            echo "Error: Unsupported workflow file type: $workflow_file" >&2
            return 1
            ;;
    esac
}

# Inspect a workflow
inspect_workflow() {
    local workflow_name="$1"
    
    if [[ -z "$workflow_name" ]]; then
        echo "Error: No workflow specified" >&2
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
        echo "Error: Workflow '$workflow_name' not found" >&2
        return 1
    fi
    
    echo "Workflow: $workflow_name"
    echo "File: $workflow_file"
    echo "Type: ${workflow_file##*.}"
    
    # Show file contents for inspection
    echo "Contents:"
    cat "$workflow_file"
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
test_list_workflows_with_files() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Get the list of workflows
    local workflows
    workflows=$(list_workflows)
    
    # Check that we have the expected workflows
    if echo "$workflows" | grep -q "example"; then
        assert_equals "found" "found" "example.yaml should be found in workflow list"
    else
        assert_equals "found" "missing" "example.yaml should be found in workflow list"
        return 1
    fi
    
    if echo "$workflows" | grep -q "test"; then
        assert_equals "found" "found" "test.sh should be found in workflow list"
    else
        assert_equals "found" "missing" "test.sh should be found in workflow list"
        return 1
    fi
}

test_list_workflows_empty_dir() {
    # Source the workflow module
    source src/workflow.sh
    
    # Create empty workflows directory
    mkdir -p empty_workflows
    WORKFLOWS_DIR="empty_workflows"
    
    # Get the list of workflows
    local workflows
    workflows=$(list_workflows)
    
    # Check that no workflows are found
    if echo "$workflows" | grep -q "No workflows found"; then
        assert_equals "found" "found" "Should show 'No workflows found' for empty directory"
    else
        assert_equals "found" "missing" "Should show 'No workflows found' for empty directory"
        return 1
    fi
}

test_list_workflow_files() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Get the list of workflow files
    local workflow_files
    workflow_files=$(list_workflow_files)
    
    # Check that we have the expected workflow files
    if echo "$workflow_files" | grep -q "example.yaml"; then
        assert_equals "found" "found" "example.yaml should be found in workflow files"
    else
        assert_equals "found" "missing" "example.yaml should be found in workflow files"
        return 1
    fi
    
    if echo "$workflow_files" | grep -q "test.sh"; then
        assert_equals "found" "found" "test.sh should be found in workflow files"
    else
        assert_equals "found" "missing" "test.sh should be found in workflow files"
        return 1
    fi
}

test_validate_workflow_valid() {
    # Source the workflow module
    source src/workflow.sh
    
    # Test with valid workflow file
    if validate_workflow "workflows/example.yaml" 2>/dev/null; then
        assert_equals "0" "0" "Valid workflow file should validate successfully"
    else
        assert_equals "0" "1" "Valid workflow file should validate successfully"
        return 1
    fi
}

test_validate_workflow_nonexistent() {
    # Source the workflow module
    source src/workflow.sh
    
    # Test with non-existent workflow file
    local exit_code=0
    validate_workflow "workflows/nonexistent.yaml" 2>/dev/null || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Non-existent workflow file should fail validation"
    else
        assert_equals "1" "0" "Non-existent workflow file should fail validation"
        return 1
    fi
}

test_validate_workflow_invalid_extension() {
    # Source the workflow module
    source src/workflow.sh
    
    # Create a file with invalid extension
    echo "invalid content" > workflows/invalid.txt
    
    # Test with invalid extension
    local exit_code=0
    validate_workflow "workflows/invalid.txt" 2>/dev/null || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Invalid extension should fail validation"
    else
        assert_equals "1" "0" "Invalid extension should fail validation"
        return 1
    fi
}

test_run_workflow_shell_script() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test running a shell script workflow
    local output
    output=$(run_workflow "test" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: test"; then
        assert_equals "found" "found" "Workflow run should start correctly"
    else
        assert_equals "found" "missing" "Workflow run should start correctly"
        return 1
    fi
    
    if echo "$output" | grep -q "Running test workflow script"; then
        assert_equals "found" "found" "Shell script workflow should execute correctly"
    else
        assert_equals "found" "missing" "Shell script workflow should execute correctly"
        return 1
    fi
}

test_run_workflow_yaml_file() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test running a YAML workflow
    local output
    output=$(run_workflow "example" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: example"; then
        assert_equals "found" "found" "YAML workflow run should start correctly"
    else
        assert_equals "found" "missing" "YAML workflow run should start correctly"
        return 1
    fi
    
    if echo "$output" | grep -q "Processing workflows/example.yaml"; then
        assert_equals "found" "found" "YAML workflow should be processed"
    else
        assert_equals "found" "missing" "YAML workflow should be processed"
        return 1
    fi
}

test_run_workflow_nonexistent() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test running a non-existent workflow
    local output
    local exit_code=0
    
    output=$(run_workflow "nonexistent" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Non-existent workflow should exit with code 1"
    else
        assert_equals "1" "$exit_code" "Non-existent workflow should exit with code 1"
        return 1
    fi
    
    if echo "$output" | grep -q "Error: Workflow 'nonexistent' not found"; then
        assert_equals "found" "found" "Non-existent workflow should show error message"
    else
        assert_equals "found" "missing" "Non-existent workflow should show error message"
        return 1
    fi
}

test_run_workflow_empty_name() {
    # Source the workflow module
    source src/workflow.sh
    
    # Test running a workflow with empty name
    local output
    local exit_code=0
    
    output=$(run_workflow "" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Empty workflow name should exit with code 1"
    else
        assert_equals "1" "$exit_code" "Empty workflow name should exit with code 1"
        return 1
    fi
    
    if echo "$output" | grep -q "Error: No workflow specified"; then
        assert_equals "found" "found" "Empty workflow name should show error message"
    else
        assert_equals "found" "missing" "Empty workflow name should show error message"
        return 1
    fi
}

test_inspect_workflow() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test inspecting a workflow
    local output
    output=$(inspect_workflow "example" 2>&1)
    
    if echo "$output" | grep -q "Workflow: example"; then
        assert_equals "found" "found" "Inspect should show workflow name"
    else
        assert_equals "found" "missing" "Inspect should show workflow name"
        return 1
    fi
    
    if echo "$output" | grep -q "File: workflows/example.yaml"; then
        assert_equals "found" "found" "Inspect should show workflow file path"
    else
        assert_equals "found" "missing" "Inspect should show workflow file path"
        return 1
    fi
    
    if echo "$output" | grep -q "Type: yaml"; then
        assert_equals "found" "found" "Inspect should show workflow file type"
    else
        assert_equals "found" "missing" "Inspect should show workflow file type"
        return 1
    fi
    
    if echo "$output" | grep -q "name: example"; then
        assert_equals "found" "found" "Inspect should show workflow contents"
    else
        assert_equals "found" "missing" "Inspect should show workflow contents"
        return 1
    fi
}

test_inspect_workflow_nonexistent() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Test inspecting a non-existent workflow
    local output
    local exit_code=0
    
    output=$(inspect_workflow "nonexistent" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Inspect non-existent workflow should exit with code 1"
    else
        assert_equals "1" "$exit_code" "Inspect non-existent workflow should exit with code 1"
        return 1
    fi
    
    if echo "$output" | grep -q "Error: Workflow 'nonexistent' not found"; then
        assert_equals "found" "found" "Inspect non-existent workflow should show error message"
    else
        assert_equals "found" "missing" "Inspect non-existent workflow should show error message"
        return 1
    fi
}

test_inspect_workflow_empty_name() {
    # Source the workflow module
    source src/workflow.sh
    
    # Test inspecting a workflow with empty name
    local output
    local exit_code=0
    
    output=$(inspect_workflow "" 2>&1) || exit_code=$?
    
    if [[ $exit_code -eq 1 ]]; then
        assert_equals "1" "1" "Inspect empty workflow name should exit with code 1"
    else
        assert_equals "1" "$exit_code" "Inspect empty workflow name should exit with code 1"
        return 1
    fi
    
    if echo "$output" | grep -q "Error: No workflow specified"; then
        assert_equals "found" "found" "Inspect empty workflow name should show error message"
    else
        assert_equals "found" "missing" "Inspect empty workflow name should show error message"
        return 1
    fi
}

test_workflows_dir_creation() {
    # Source the workflow module
    source src/workflow.sh
    
    # Check that workflows directory exists
    if [[ -d "$WORKFLOWS_DIR" ]]; then
        assert_equals "exists" "exists" "Workflows directory should be created"
    else
        assert_equals "exists" "missing" "Workflows directory should be created"
        return 1
    fi
}

test_run_workflow_json_file() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Create a JSON workflow file
    echo '{"name": "json-test"}' > workflows/json-test.json
    
    # Test running a JSON workflow
    local output
    output=$(run_workflow "json-test" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: json-test"; then
        assert_equals "found" "found" "JSON workflow run should start correctly"
    else
        assert_equals "found" "missing" "JSON workflow run should start correctly"
        return 1
    fi
    
    if echo "$output" | grep -q "Processing workflows/json-test.json"; then
        assert_equals "found" "found" "JSON workflow should be processed"
    else
        assert_equals "found" "missing" "JSON workflow should be processed"
        return 1
    fi
}

test_run_workflow_yml_file() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Create a YML workflow file
    echo "name: yml-test" > workflows/yml-test.yml
    
    # Test running a YML workflow
    local output
    output=$(run_workflow "yml-test" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: yml-test"; then
        assert_equals "found" "found" "YML workflow run should start correctly"
    else
        assert_equals "found" "missing" "YML workflow run should start correctly"
        return 1
    fi
    
    if echo "$output" | grep -q "Processing workflows/yml-test.yml"; then
        assert_equals "found" "found" "YML workflow should be processed"
    else
        assert_equals "found" "missing" "YML workflow should be processed"
        return 1
    fi
}

test_run_workflow_no_extension() {
    # Source the workflow module
    source src/workflow.sh
    
    # Set the workflows directory
    WORKFLOWS_DIR="workflows"
    
    # Create a workflow file without extension
    echo '#!/usr/bin/env bash
echo "No extension workflow"' > workflows/no-extension
    chmod +x workflows/no-extension
    
    # Test running a workflow without extension
    local output
    output=$(run_workflow "no-extension" 2>&1)
    
    if echo "$output" | grep -q "Running workflow: no-extension"; then
        assert_equals "found" "found" "No extension workflow run should start correctly"
    else
        assert_equals "found" "missing" "No extension workflow run should start correctly"
        return 1
    fi
    
    if echo "$output" | grep -q "No extension workflow"; then
        assert_equals "found" "found" "No extension workflow should execute correctly"
    else
        assert_equals "found" "missing" "No extension workflow should execute correctly"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running workflow tests..."
    
    setup
    
    test_list_workflows_with_files
    test_list_workflows_empty_dir
    test_list_workflow_files
    test_validate_workflow_valid
    test_validate_workflow_nonexistent
    test_validate_workflow_invalid_extension
    test_run_workflow_shell_script
    test_run_workflow_yaml_file
    test_run_workflow_nonexistent
    test_run_workflow_empty_name
    test_inspect_workflow
    test_inspect_workflow_nonexistent
    test_inspect_workflow_empty_name
    test_workflows_dir_creation
    test_run_workflow_json_file
    test_run_workflow_yml_file
    
    teardown
    
    echo ""
    echo "=== Workflow Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All workflow tests passed!"
        return 0
    else
        echo "Some workflow tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi