#!/usr/bin/env bash
# Logging module for conductor

set -euo pipefail

# Default log level is INFO
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_DIR="${LOG_DIR:-$PROJECT_ROOT/logs}"

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