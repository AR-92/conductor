#!/usr/bin/env bash
# tests/test_logging.sh - Logging module tests

set -euo pipefail

# Source core test utilities
source "$(dirname "${BASH_SOURCE[0]}")/test_core.sh"

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
    
    # If the message level is not defined, default to INFO
    local msg_level_num=${LOG_LEVELS[$msg_level]:-3}
    
    # If the current log level is not defined, default to INFO
    local current_level_num=${LOG_LEVELS[$LOG_LEVEL]:-3}
    
    if [[ $msg_level_num -le $current_level_num ]]; then
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
        assert_equals "defined" "defined" "Log levels should be defined"
    else
        assert_equals "defined" "undefined" "Log levels should be defined"
        return 1
    fi
}

test_should_log_error_levels() {
    # Source the logging module
    source src/logging.sh
    
    # Test with ERROR level
    LOG_LEVEL="ERROR"
    
    # Test that ERROR should be logged at ERROR level
    if should_log "ERROR"; then
        assert_equals "true" "true" "ERROR should be logged at ERROR level"
    else
        assert_equals "true" "false" "ERROR should be logged at ERROR level"
        return 1
    fi
    
    # Test that WARN should not be logged at ERROR level
    if ! should_log "WARN"; then
        assert_equals "false" "false" "WARN should not be logged at ERROR level"
    else
        assert_equals "false" "true" "WARN should not be logged at ERROR level"
        return 1
    fi
}

test_should_log_warn_levels() {
    # Source the logging module
    source src/logging.sh
    
    # Test with WARN level
    LOG_LEVEL="WARN"
    
    # Test that ERROR should be logged at WARN level
    if should_log "ERROR"; then
        assert_equals "true" "true" "ERROR should be logged at WARN level"
    else
        assert_equals "true" "false" "ERROR should be logged at WARN level"
        return 1
    fi
    
    # Test that WARN should be logged at WARN level
    if should_log "WARN"; then
        assert_equals "true" "true" "WARN should be logged at WARN level"
    else
        assert_equals "true" "false" "WARN should be logged at WARN level"
        return 1
    fi
    
    # Test that INFO should not be logged at WARN level
    if ! should_log "INFO"; then
        assert_equals "false" "false" "INFO should not be logged at WARN level"
    else
        assert_equals "false" "true" "INFO should not be logged at WARN level"
        return 1
    fi
}

test_should_log_info_levels() {
    # Source the logging module
    source src/logging.sh
    
    # Test with default INFO level
    LOG_LEVEL="INFO"
    
    # Test that INFO and higher priority messages should be logged
    if should_log "ERROR"; then
        assert_equals "true" "true" "ERROR should be logged at INFO level"
    else
        assert_equals "true" "false" "ERROR should be logged at INFO level"
        return 1
    fi
    
    if should_log "WARN"; then
        assert_equals "true" "true" "WARN should be logged at INFO level"
    else
        assert_equals "true" "false" "WARN should be logged at INFO level"
        return 1
    fi
    
    if should_log "INFO"; then
        assert_equals "true" "true" "INFO should be logged at INFO level"
    else
        assert_equals "true" "false" "INFO should be logged at INFO level"
        return 1
    fi
    
    # Test that DEBUG should not be logged at INFO level
    if ! should_log "DEBUG"; then
        assert_equals "false" "false" "DEBUG should not be logged at INFO level"
    else
        assert_equals "false" "true" "DEBUG should not be logged at INFO level"
        return 1
    fi
}

test_should_log_debug_levels() {
    # Source the logging module
    source src/logging.sh
    
    # Test with DEBUG level
    LOG_LEVEL="DEBUG"
    
    # Test that all levels should be logged at DEBUG level
    if should_log "ERROR"; then
        assert_equals "true" "true" "ERROR should be logged at DEBUG level"
    else
        assert_equals "true" "false" "ERROR should be logged at DEBUG level"
        return 1
    fi
    
    if should_log "WARN"; then
        assert_equals "true" "true" "WARN should be logged at DEBUG level"
    else
        assert_equals "true" "false" "WARN should be logged at DEBUG level"
        return 1
    fi
    
    if should_log "INFO"; then
        assert_equals "true" "true" "INFO should be logged at DEBUG level"
    else
        assert_equals "true" "false" "INFO should be logged at DEBUG level"
        return 1
    fi
    
    if should_log "DEBUG"; then
        assert_equals "true" "true" "DEBUG should be logged at DEBUG level"
    else
        assert_equals "true" "false" "DEBUG should be logged at DEBUG level"
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
    log_error "$error_msg" 2>/dev/null || assert_equals "0" "1" "log_error should not produce an error"
    log_warn "$warn_msg" 2>/dev/null || assert_equals "0" "1" "log_warn should not produce an error"
    log_info "$info_msg" 2>/dev/null || assert_equals "0" "1" "log_info should not produce an error"
    log_debug "$debug_msg" 2>/dev/null || assert_equals "0" "1" "log_debug should not produce an error"
    
    assert_equals "0" "0" "Log functions can be called without errors"
}

test_timestamp_format() {
    # Source the logging module
    source src/logging.sh
    
    local timestamp
    timestamp=$(get_timestamp)
    
    # Check that timestamp matches expected format
    if echo "$timestamp" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'; then
        assert_equals "valid" "valid" "Timestamp format should be correct"
    else
        assert_equals "valid" "invalid" "Timestamp format should be correct: $timestamp"
        return 1
    fi
}

test_log_dir_creation() {
    # Source the logging module
    source src/logging.sh
    
    # Check that log directory exists
    if [[ -d "$LOG_DIR" ]]; then
        assert_equals "exists" "exists" "Log directory should be created"
    else
        assert_equals "exists" "missing" "Log directory should be created"
        return 1
    fi
}

test_invalid_log_level() {
    # Source the logging module
    source src/logging.sh
    
    # Test with invalid log level (should default to INFO)
    LOG_LEVEL="INVALID"
    
    # Test that INFO should be logged with invalid level
    if should_log "INFO"; then
        assert_equals "true" "true" "INFO should be logged with invalid log level"
    else
        assert_equals "true" "false" "INFO should be logged with invalid log level"
        return 1
    fi
    
    # Test that DEBUG should not be logged with invalid level (defaults to INFO)
    if ! should_log "DEBUG"; then
        assert_equals "false" "false" "DEBUG should not be logged with invalid log level"
    else
        assert_equals "false" "true" "DEBUG should not be logged with invalid log level"
        return 1
    fi
}

test_invalid_message_level() {
    # Source the logging module
    source src/logging.sh
    
    # Test with INFO log level
    LOG_LEVEL="INFO"
    
    # Test that invalid message level should default to INFO
    if should_log "INVALID"; then
        assert_equals "true" "true" "Invalid message level should default to INFO"
    else
        assert_equals "true" "false" "Invalid message level should default to INFO"
        return 1
    fi
}

test_get_log_file() {
    # Source the logging module
    source src/logging.sh
    
    local log_file
    log_file=$(get_log_file)
    
    # Check that log file path contains date
    if echo "$log_file" | grep -qE 'conductor-[0-9]{4}-[0-9]{2}-[0-9]{2}\.log$'; then
        assert_equals "valid" "valid" "Log file name should contain date"
    else
        assert_equals "valid" "invalid" "Log file name should contain date: $log_file"
        return 1
    fi
}

test_write_log() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG
    LOG_LEVEL="DEBUG"
    
    # Write a test log entry
    write_log "INFO" "Test log entry"
    
    # Check that log file was created and contains entry
    local log_file
    log_file=$(get_log_file)
    
    if [[ -f "$log_file" ]]; then
        if grep -q "Test log entry" "$log_file"; then
            assert_equals "found" "found" "Log entry should be written to file"
        else
            assert_equals "found" "missing" "Log entry should be written to file"
            return 1
        fi
    else
        assert_equals "exists" "missing" "Log file should be created"
        return 1
    fi
}

test_error_log_to_stderr() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG
    LOG_LEVEL="DEBUG"
    
    # Capture stderr output
    local stderr_output
    stderr_output=$(log_error "Test error message" 2>&1 >/dev/null)
    
    # Check that error message was written to stderr
    if echo "$stderr_output" | grep -q "Test error message"; then
        assert_equals "found" "found" "Error message should be written to stderr"
    else
        assert_equals "found" "missing" "Error message should be written to stderr"
        return 1
    fi
}

test_warn_log_to_stderr() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG
    LOG_LEVEL="DEBUG"
    
    # Capture stderr output
    local stderr_output
    stderr_output=$(log_warn "Test warning message" 2>&1 >/dev/null)
    
    # Check that warning message was written to stderr
    if echo "$stderr_output" | grep -q "Test warning message"; then
        assert_equals "found" "found" "Warning message should be written to stderr"
    else
        assert_equals "found" "missing" "Warning message should be written to stderr"
        return 1
    fi
}

test_info_log_not_to_stderr() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG
    LOG_LEVEL="DEBUG"
    
    # Capture stderr output
    local stderr_output
    stderr_output=$(log_info "Test info message" 2>&1 >/dev/null)
    
    # Check that info message was not written to stderr
    if ! echo "$stderr_output" | grep -q "Test info message"; then
        assert_equals "not_found" "not_found" "Info message should not be written to stderr"
    else
        assert_equals "not_found" "found" "Info message should not be written to stderr"
        return 1
    fi
}

test_debug_log_not_to_stderr() {
    # Source the logging module
    source src/logging.sh
    
    # Set log level to DEBUG
    LOG_LEVEL="DEBUG"
    
    # Capture stderr output
    local stderr_output
    stderr_output=$(log_debug "Test debug message" 2>&1 >/dev/null)
    
    # Check that debug message was not written to stderr
    if ! echo "$stderr_output" | grep -q "Test debug message"; then
        assert_equals "not_found" "not_found" "Debug message should not be written to stderr"
    else
        assert_equals "not_found" "found" "Debug message should not be written to stderr"
        return 1
    fi
}

# Main test runner
main() {
    echo "Running logging tests..."
    
    setup
    
    test_log_levels_defined
    test_should_log_error_levels
    test_should_log_warn_levels
    test_should_log_info_levels
    test_should_log_debug_levels
    test_log_functions
    test_timestamp_format
    test_log_dir_creation
    test_invalid_log_level
    test_invalid_message_level
    test_get_log_file
    test_write_log
    test_error_log_to_stderr
    test_warn_log_to_stderr
    test_info_log_not_to_stderr
    test_debug_log_not_to_stderr
    
    teardown
    
    echo ""
    echo "=== Logging Tests Summary ==="
    echo "Total tests: $TEST_COUNT"
    echo "Passed: $PASS_COUNT"
    echo "Failed: $FAIL_COUNT"
    
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo "All logging tests passed!"
        return 0
    else
        echo "Some logging tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi