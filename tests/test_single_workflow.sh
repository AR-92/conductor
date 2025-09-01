#!/usr/bin/env bash
# tests/test_single_workflow.sh - Test single workflow function

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
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
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
    echo "Running single workflow test..."
    
    setup
    test_run_workflow_no_extension
    teardown
    
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