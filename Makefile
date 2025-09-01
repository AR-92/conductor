# Makefile for conductor CLI tool

# Default target
.PHONY: test test-all lint clean run help install-shellcheck

# Variables
TEST_DIR := tests
SRC_DIR := src
BIN_DIR := bin

# Help target
help:
	@echo "conductor - CLI tool for orchestrating workflows"
	@echo ""
	@echo "Usage:"
	@echo "  make test     - Run all tests"
	@echo "  make test-all - Run all tests with detailed output"
	@echo "  make lint     - Run shellcheck linting"
	@echo "  make clean    - Clean up temporary files"
	@echo "  make run      - Run the conductor CLI tool"

# Test target - run all test scripts
test:
	@echo "Running all tests..."
	@bash $(TEST_DIR)/test_cli.sh
	@bash $(TEST_DIR)/test_logging.sh
	@bash $(TEST_DIR)/test_workflow.sh
	@echo "All tests passed!"

# Test target with detailed output
test-all:
	@echo "Running CLI tests..."
	@bash $(TEST_DIR)/test_cli.sh
	@echo ""
	@echo "Running logging tests..."
	@bash $(TEST_DIR)/test_logging.sh
	@echo ""
	@echo "Running workflow tests..."
	@bash $(TEST_DIR)/test_workflow.sh
	@echo ""
	@echo "All tests passed!"

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