#!/usr/bin/env bash
# tests/test_conductor_main.sh - Tests for the main conductor script

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
    
    # Copy the conductor script for testing
    cp /home/rana/Documents/Projects/conductor/bin/conductor bin/
    
    # Create a minimal src directory
    mkdir -p src
    echo '#!/usr/bin/env bash' > src/logging.sh
    echo '#!/usr/bin/env bash' > src/cli.sh
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test functions
test_conductor_script_exists() {
    # Check that conductor script exists
    if [[ -f "bin/conductor" ]]; then
        assert_equals "exists" "exists" "Conductor script should exist"
    else
        assert_equals "exists" "missing" "Conductor script should exist"
        return 1
    fi
}

test_conductor_script_executable() {
    # Check that conductor script is executable
    if [[ -x "bin/conductor" ]]; then
        assert_equals "executable" "executable" "Conductor script should be executable"
    else
        assert_equals "executable" "not executable" "Conductor script should be executable"
        return 1
    fi
}

test_conductor_script_has_bang_line() {
    # Check that conductor script has the correct bang line
    local first_line
    first_line=$(head -n 1 bin/conductor)
    
    if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        assert_equals "#!/usr/bin/env bash" "#!/usr/bin/env bash" "Conductor script should have correct bang line"
    else
        assert_equals "#!/usr/bin/env bash" "$first_line" "Conductor script should have correct bang line"
        return 1
    fi
}

test_conductor_script_has_set_euo_pipefail() {
    # Check that conductor script has set -euo pipefail
    if grep -q "set -euo pipefail" bin/conductor; then
        assert_equals "found" "found" "Conductor script should have set -euo pipefail"
    else
        assert_equals "found" "missing" "Conductor script should have set -euo pipefail"
        return 1
    fi
}

test_conductor_script_sources_modules() {
    # Check that conductor script sources required modules
    local sources_count
    sources_count=$(grep -c "source " bin/conductor 2>/dev/null || echo "0")
    
    if [[ $sources_count -ge 1 ]]; then
        assert_equals ">=1" ">=1" "Conductor script should source required modules"
    else
        assert_equals ">=1" "$sources_count" "Conductor script should source required modules"
        return 1
    fi
}

test_conductor_script_has_main_function() {
    # Check that conductor script has a main function
    if grep -q "main()" bin/conductor; then
        assert_equals "found" "found" "Conductor script should have main function"
    else
        assert_equals "found" "missing" "Conductor script should have main function"
        return 1
    fi
}

test_conductor_script_calls_main() {
    # Check that conductor script calls main function
    if grep -q "main \"\\$@\"" bin/conductor; then
        assert_equals "found" "found" "Conductor script should call main function"
    else
        # Try alternative pattern
        if grep -q "main \"\$@\"" bin/conductor; then
            assert_equals "found" "found" "Conductor script should call main function"
        else
            assert_equals "found" "missing" "Conductor script should call main function"
            return 1
        fi
    fi
}

test_conductor_script_has_project_root() {
    # Check that conductor script defines PROJECT_ROOT
    if grep -q "PROJECT_ROOT" bin/conductor; then
        assert_equals "found" "found" "Conductor script should define PROJECT_ROOT"
    else
        assert_equals "found" "missing" "Conductor script should define PROJECT_ROOT"
        return 1
    fi
}

test_conductor_script_exports_project_root() {
    # Check that conductor script exports PROJECT_ROOT
    if grep -q "export PROJECT_ROOT" bin/conductor; then
        assert_equals "found" "found" "Conductor script should export PROJECT_ROOT"
    else
        assert_equals "found" "missing" "Conductor script should export PROJECT_ROOT"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running conductor main script tests..."
    
    setup
    
    test_conductor_script_exists
    test_conductor_script_executable
    test_conductor_script_has_bang_line
    test_conductor_script_has_set_euo_pipefail
    test_conductor_script_sources_modules
    test_conductor_script_has_main_function
    test_conductor_script_calls_main
    test_conductor_script_has_project_root
    test_conductor_script_exports_project_root
    
    teardown
    
    echo ""
    echo "=== Conductor Main Script Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All conductor main script tests passed!"
        return 0
    else
        echo "Some conductor main script tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi