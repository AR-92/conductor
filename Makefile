# Makefile for conductor CLI tool

# Default target
.PHONY: test test-all test-advanced lint clean run help install-shellcheck

# Variables
TEST_DIR := tests
SRC_DIR := src
BIN_DIR := bin

# Help target
help:
	@echo "conductor - CLI tool for orchestrating workflows"
	@echo ""
	@echo "Usage:"
	@echo "  make test           - Run all tests"
	@echo "  make test-all       - Run all tests with detailed output"
	@echo "  make test-advanced  - Run advanced workflow tests"
	@echo "  make lint           - Run shellcheck linting"
	@echo "  make clean          - Clean up temporary files"
	@echo "  make run            - Run the conductor CLI tool"

# Test target - run all test scripts
test:
	@echo "Running all tests..."
	@bash $(TEST_DIR)/test_cli.sh >/dev/null 2>&1 && echo "CLI tests passed!" || (echo "CLI tests failed!"; exit 1)
	@bash $(TEST_DIR)/test_logging.sh >/dev/null 2>&1 && echo "Logging tests passed!" || (echo "Logging tests failed!"; exit 1)
	@bash $(TEST_DIR)/test_workflow.sh >/dev/null 2>&1 && echo "Workflow tests passed!" || (echo "Workflow tests failed!"; exit 1)
	@bash $(TEST_DIR)/test_helpers.sh >/dev/null 2>&1 && echo "Helpers tests passed!" || (echo "Helpers tests failed!"; exit 1)
	@bash $(TEST_DIR)/test_advanced_simple.sh >/dev/null 2>&1 && echo "Advanced workflow tests passed!" || (echo "Advanced workflow tests failed!"; exit 1)
	@bash $(TEST_DIR)/test_conductor_main.sh >/dev/null 2>&1 && echo "Conductor main script tests passed!" || (echo "Conductor main script tests failed!"; exit 1)
	@echo "All tests passed!"

# Test target with detailed output
test-all:
	@echo "Running CLI tests..."
	@bash $(TEST_DIR)/test_cli.sh || exit 1
	@echo ""
	@echo "Running logging tests..."
	@bash $(TEST_DIR)/test_logging.sh || exit 1
	@echo ""
	@echo "Running workflow tests..."
	@bash $(TEST_DIR)/test_workflow.sh || exit 1
	@echo ""
	@echo "Running helpers tests..."
	@bash $(TEST_DIR)/test_helpers.sh || exit 1
	@echo ""
	@echo "Running advanced workflow tests..."
	@bash $(TEST_DIR)/test_advanced_simple.sh || exit 1
	@echo ""
	@echo "Running conductor main script tests..."
	@bash $(TEST_DIR)/test_conductor_main.sh || exit 1
	@echo ""
	@echo "All tests passed!"

# Test helpers only
test-helpers:
	@echo "Running helpers tests..."
	@bash $(TEST_DIR)/test_helpers.sh

# Test conductor main script only
test-conductor:
	@echo "Running conductor main script tests..."
	@bash $(TEST_DIR)/test_conductor_main.sh

# Lint target (requires shellcheck)
lint:
	@echo "Running shellcheck..."
	@find $(SRC_DIR) $(TEST_DIR) $(BIN_DIR) -name "*.sh" -exec shellcheck {} +

# Clean target
clean:
	@echo "Cleaning up..."
	@rm -f logs/*.log
	@echo "Clean complete."

# Run target
run:
	@$(BIN_DIR)/conductor

# Install shellcheck if not present (Debian/Ubuntu)
install-shellcheck:
	@command -v shellcheck >/dev/null || (echo "Installing shellcheck..." && sudo apt-get update && sudo apt-get install -y shellcheck)