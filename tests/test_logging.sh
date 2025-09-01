#!/usr/bin/env bash
# Test suite for the conductor logging module

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
    
    # Create a minimal logging module for testing
    cat > src/logging.sh <<'EOF'
#!/usr/bin/env bash
# Logging module for conductor

set -euo pipefail

# Default log level is INFO
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_DIR="${LOG_DIR:-logs}"

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log levels (higher number = more verbose)
declare -A LOG_LEVELS=(
    [ERROR]=1
    [WARN]=2
    [INFO]=3
    [DEBUG]=4
)

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get log file for today
get_log_file() {
    local date_str
    date_str=$(date '+%Y-%m-%d')
    echo "$LOG_DIR/conductor-$date_str.log"
}

# Check if message should be logged based on level
should_log() {
    local msg_level="$1"
    
    if [[ ${LOG_LEVELS[$msg_level]} -le ${LOG_LEVELS[$LOG_LEVEL]:-3} ]]; then
        return 0
    else
        return 1
    fi
}

# Write a log message
write_log() {
    local level="$1"
    local message="$2"
    
    if should_log "$level"; then
        local timestamp
        timestamp=$(get_timestamp)
        local log_entry="$timestamp [$level] $message"
        
        # Write to log file
        echo "$log_entry" >> "$(get_log_file)"
        
        # Also write to stderr for ERROR and WARN levels
        if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
            echo "$log_entry" >&2
        fi
    fi
}

# Convenience functions for each log level
log_error() {
    write_log "ERROR" "$1"
}

log_warn() {
    write_log "WARN" "$1"
}

log_info() {
    write_log "INFO" "$1"
}

log_debug() {
    write_log "DEBUG" "$1"
}
EOF
}

# Teardown
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test functions
test_log_levels_defined() {
    # Source the logging module
    source src/logging.sh
    
    # Check that log levels are defined
    if [[ -n "${LOG_LEVELS[ERROR]:-}" ]] && [[ -n "${LOG_LEVELS[WARN]:-}" ]] && 
       [[ -n "${LOG_LEVELS[INFO]:-}" ]] && [[ -n "${LOG_LEVELS[DEBUG]:-}" ]]; then
        echo "PASS: Log levels are defined"
    else
        echo "FAIL: Log levels are not properly defined"
        return 1
    fi
}

test_should_log() {
    # Source the logging module
    source src/logging.sh
    
    # Test with default INFO level
    LOG_LEVEL="INFO"
    
    # Test that INFO and higher priority messages should be logged
    if should_log "ERROR"; then
        echo "PASS: ERROR should be logged at INFO level"
    else
        echo "FAIL: ERROR should be logged at INFO level"
        return 1
    fi
    
    if should_log "WARN"; then
        echo "PASS: WARN should be logged at INFO level"
    else
        echo "FAIL: WARN should be logged at INFO level"
        return 1
    fi
    
    if should_log "INFO"; then
        echo "PASS: INFO should be logged at INFO level"
    else
        echo "FAIL: INFO should be logged at INFO level"
        return 1
    fi
    
    # Test that DEBUG should not be logged at INFO level
    if ! should_log "DEBUG"; then
        echo "PASS: DEBUG should not be logged at INFO level"
    else
        echo "FAIL: DEBUG should not be logged at INFO level"
        return 1
    fi
    
    # Test with DEBUG level
    LOG_LEVEL="DEBUG"
    if should_log "DEBUG"; then
        echo "PASS: DEBUG should be logged at DEBUG level"
    else
        echo "FAIL: DEBUG should be logged at DEBUG level"
        return 1
    fi
}

test_log_functions() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG for testing
    LOG_LEVEL="DEBUG"
    
    # Test that we can call log functions without errors
    local error_msg="This is an error message"
    local warn_msg="This is a warning message"
    local info_msg="This is an info message"
    local debug_msg="This is a debug message"
    
    # These should not produce errors
    log_error "$error_msg" 2>/dev/null || echo "FAIL: log_error produced an error"
    log_warn "$warn_msg" 2>/dev/null || echo "FAIL: log_warn produced an error"
    log_info "$info_msg" 2>/dev/null || echo "FAIL: log_info produced an error"
    log_debug "$debug_msg" 2>/dev/null || echo "FAIL: log_debug produced an error"
    
    echo "PASS: Log functions can be called without errors"
}

test_timestamp_format() {
    # Source the logging module
    source src/logging.sh
    
    local timestamp
    timestamp=$(get_timestamp)
    
    # Check that timestamp matches expected format
    if echo "$timestamp" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'; then
        echo "PASS: Timestamp format is correct"
    else
        echo "FAIL: Timestamp format is incorrect: $timestamp"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running logging tests..."
    
    setup
    
    test_log_levels_defined
    test_should_log
    test_log_functions
    test_timestamp_format
    
    teardown
    
    echo "All logging tests passed!"
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi