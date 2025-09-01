# conductor

A CLI tool for orchestrating and running workflows with composable steps.

## Features

- Define workflows as YAML/JSON files or shell scripts
- Run, list, and inspect workflows
- Comprehensive logging with multiple log levels and daily rotation
- Professional CLI with help and version commands
- Test-driven development with comprehensive test suite

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/conductor.git
cd conductor

# Make the conductor script executable
chmod +x bin/conductor

# Run the tool
./bin/conductor --help
```

## Usage

```bash
# Show help
./bin/conductor --help

# Show version
./bin/conductor --version

# List workflows
./bin/conductor list

# Run a workflow
./bin/conductor run workflow-name

# Inspect a workflow
./bin/conductor inspect workflow-name
```

## Workflow Files

Workflows can be defined in the `workflows/` directory with the following extensions:
- `.yaml` or `.yml` for YAML workflows
- `.json` for JSON workflows
- `.sh` for shell script workflows

### Example YAML Workflow

```yaml
name: build-and-test
steps:
  - name: build
    command: make build
  - name: test
    command: make test
```

### Example Shell Script Workflow

```bash
#!/usr/bin/env bash
# deploy.sh
echo "Deploying application..."
# Add deployment commands here
```

## Development

### Running Tests

```bash
# Run all tests
make test

# Run all tests with detailed output
make test-all
```

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

## Project Structure

```
conductor/
├── bin/           # CLI entry point scripts
│   └── conductor
├── src/           # core bash scripts
│   ├── logging.sh
│   ├── workflow.sh
│   ├── helpers.sh
│   └── cli.sh
├── tests/         # unit and integration tests
│   ├── test_logging.sh
│   ├── test_cli.sh
│   └── test_workflow.sh
├── docs/          # documentation
│   └── usage.md
├── workflows/     # workflow definitions
│   ├── build-and-test.yaml
│   └── deploy.sh
├── logs/          # log files (runtime generated)
├── Makefile       # for building, running tests, cleaning
├── VERSION        # version file
└── README.md
```