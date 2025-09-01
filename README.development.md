## Development

### Running Tests

```bash
# Run all tests
make test

# Run all tests with detailed output
make test-all

# Run specific test suites
make test-helpers    # Run helpers tests
make test-conductor  # Run conductor main script tests
```

### Test Coverage

conductor maintains 100% test coverage with over 100 individual tests covering:
- CLI interface functionality
- Logging system with multiple log levels
- Workflow processing and validation
- Helper functions for common operations
- Advanced workflow features (parallel execution, conditional steps, loops, chaining)
- Main conductor script functionality

All tests follow Test-Driven Development (TDD) principles with comprehensive coverage.

### Linting

```bash
# Run shellcheck linting (requires shellcheck)
make lint
```

### Cleaning

```bash
# Clean log files
make clean
```