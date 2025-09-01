#!/usr/bin/env bash
# tests/test_simple_debug.sh - Simple debug test

set -euo pipefail

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Create the basic conductor structure for testing
mkdir -p workflows

# Create a workflow file without extension
echo '#!/usr/bin/env bash
echo "No extension workflow"' > workflows/no-extension
chmod +x workflows/no-extension

# Simple function to run a workflow
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
        if [[ -f "workflows/$workflow_name.$ext" ]]; then
            workflow_file="workflows/$workflow_name.$ext"
            break
        fi
    done
    
    # If not found with extension, check without extension
    if [[ -z "$workflow_file" ]] && [[ -f "workflows/$workflow_name" ]]; then
        workflow_file="workflows/$workflow_name"
    fi
    
    if [[ -z "$workflow_file" ]]; then
        echo "Error: Workflow '$workflow_name' not found" >&2
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

# Test running a workflow without extension
echo "Testing workflow execution..."
output=$(run_workflow "no-extension" 2>&1)
echo "Output: $output"

# Check the output
if echo "$output" | grep -q "Running workflow: no-extension"; then
    echo "First check passed"
else
    echo "First check failed"
fi

if echo "$output" | grep -q "No extension workflow"; then
    echo "Second check passed"
else
    echo "Second check failed"
fi

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo "Debug test completed"