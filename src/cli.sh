#!/usr/bin/env bash
# CLI module for conductor

set -euo pipefail

# Function to display help information
show_help() {
    cat << EOF
Usage: conductor [OPTIONS] COMMAND

Options:
  --help, -h     Show this help message
  --version, -v  Show version information

Commands:
  list    List available workflows
  run     Run a workflow
  inspect Inspect a workflow
EOF
}

# Function to display version information
show_version() {
    local version_file
    local script_dir
    
    # Get directory of current script
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    version_file="$script_dir/../VERSION"
    
    # Try to read version from file
    if [[ -f "$version_file" ]]; then
        cat "$version_file"
    else
        echo "0.1.0"  # Default version
    fi
}

# Function to list workflows
list_workflows() {
    # Source the workflow module
    if [[ -f "$PROJECT_ROOT/src/workflow.sh" ]]; then
        source "$PROJECT_ROOT/src/workflow.sh"
    else
        echo "Error: Could not find workflow.sh module" >&2
        return 1
    fi
    
    # Use the workflow module function
    list_workflows
}

# Function to run a workflow
run_workflow() {
    local workflow_name="$1"
    
    # Source the workflow module
    if [[ -f "$PROJECT_ROOT/src/workflow.sh" ]]; then
        source "$PROJECT_ROOT/src/workflow.sh"
    else
        echo "Error: Could not find workflow.sh module" >&2
        return 1
    fi
    
    # Use the workflow module function
    run_workflow "$workflow_name"
}

# Function to inspect a workflow
inspect_workflow() {
    local workflow_name="$1"
    
    # Source the workflow module
    if [[ -f "$PROJECT_ROOT/src/workflow.sh" ]]; then
        source "$PROJECT_ROOT/src/workflow.sh"
    else
        echo "Error: Could not find workflow.sh module" >&2
        return 1
    fi
    
    # Use the workflow module function
    inspect_workflow "$workflow_name"
}

# Function to parse command line arguments
parse_args() {
    case "${1:-}" in
        --help|-h)
            show_help
            ;;
        --version|-v)
            echo "conductor v$(show_version)"
            ;;
        list)
            list_workflows
            ;;
        run)
            if [[ -n "${2:-}" ]]; then
                run_workflow "$2"
            else
                echo "Error: No workflow specified"
                echo "Usage: conductor run <workflow-name>"
                return 1
            fi
            ;;
        inspect)
            if [[ -n "${2:-}" ]]; then
                inspect_workflow "$2"
            else
                echo "Error: No workflow specified"
                echo "Usage: conductor inspect <workflow-name>"
                return 1
            fi
            ;;
        "")
            echo "Error: No command specified"
            echo "Run 'conductor --help' for usage information"
            return 1
            ;;
        *)
            echo "Error: Unknown command '$1'"
            echo "Run 'conductor --help' for usage information"
            return 1
            ;;
    esac
}