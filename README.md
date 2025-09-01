# conductor

A powerful CLI tool for orchestrating and running workflows with composable steps. Built with pure Bash following Test-Driven Development (TDD) principles, conductor allows you to define, manage, and execute complex workflows using simple configuration files or shell scripts.

## Table of Contents

- [Features](#features)
- [Why Use Conductor?](#why-use-conductor)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Core Concepts](#core-concepts)
- [Defining Workflows](#defining-workflows)
- [Advanced Features](#advanced-features)
- [CLI Commands](#cli-commands)
- [Logging](#logging)
- [Project Structure](#project-structure)
- [Development](#development)
- [Examples](#examples)
- [Use Cases](#use-cases)

## Features

- **Multiple Workflow Formats**: Define workflows as YAML, JSON, or shell scripts
- **Composable Steps**: Build complex operations from simple, reusable steps
- **Professional CLI**: Intuitive command-line interface with help and version commands
- **Comprehensive Logging**: Multi-level logging with timestamps and daily rotation
- **Test-Driven Development**: Complete test suite covering all functionality
- **Pure Bash Implementation**: No external dependencies, runs anywhere Bash is available
- **Extensible Design**: Modular architecture for easy customization and extension
- **Advanced Workflow Features**: Parallel execution, conditional steps, loops, chaining, and AI integration

## Why Use Conductor?

### Simplify Complex Operations
Conductor transforms complex multi-step processes into simple, manageable workflows. Instead of remembering long sequences of commands, define them once and execute with a single command.

### Consistency Across Environments
Ensure operations run identically across different environments - development, staging, and production. No more "works on my machine" issues.

### Reusability
Create workflow templates that can be reused across projects. Share common deployment, testing, or build processes with your team.

### Audit Trail
Built-in logging provides a complete audit trail of all operations, making it easy to track what happened and when.

### Testability
With a comprehensive test suite following TDD principles, you can be confident that your workflows will execute correctly.

## Installation

```bash
# Clone the repository
git clone https://github.com/AR-92/conductor.git
cd conductor

# Make the conductor script executable
chmod +x bin/conductor

# (Optional) Add to your PATH for system-wide access
sudo ln -s $(pwd)/bin/conductor /usr/local/bin/conductor
```

## Quick Start

1. Create a workflow file in the `workflows/` directory:
```yaml
# workflows/deploy.yaml
name: deploy
steps:
  - name: build
    command: echo "Building application..."
  - name: test
    command: echo "Running tests..."
  - name: deploy
    command: echo "Deploying to production..."
```

2. List available workflows:
```bash
./bin/conductor list
```

3. Run your workflow:
```bash
./bin/conductor run deploy
```

## Core Concepts

### Workflows
A workflow is a sequence of steps that are executed in order. Each workflow can be defined in YAML, JSON, or as a shell script.

### Steps
A step is a single action within a workflow. Steps can be simple commands or complex operations.

### Logging
All operations are automatically logged with timestamps and categorized by severity level (ERROR, WARN, INFO, DEBUG).

## Defining Workflows

### YAML Workflows
Create a `.yaml` or `.yml` file in the `workflows/` directory:

```yaml
# workflows/build-and-test.yaml
name: build-and-test
description: Build and test the application
steps:
  - name: clean
    command: rm -rf build/
  - name: build
    command: mkdir build && cp -r src/* build/
  - name: test
    command: cd build && ./run-tests.sh
```

### JSON Workflows
Create a `.json` file in the `workflows/` directory:

```json
{
  "name": "backup",
  "description": "Backup important directories",
  "steps": [
    {
      "name": "create-timestamp",
      "command": "timestamp=$(date +%Y%m%d_%H%M%S)"
    },
    {
      "name": "backup-home",
      "command": "tar -czf backup_$timestamp.tar.gz /home/user"
    },
    {
      "name": "move-to-storage",
      "command": "mv backup_$timestamp.tar.gz /mnt/storage/"
    }
  ]
}
```

### Shell Script Workflows
Create a `.sh` file in the `workflows/` directory and make it executable:

```bash
#!/usr/bin/env bash
# workflows/deploy.sh

echo "Starting deployment process..."

# Step 1: Pull latest code
echo "Pulling latest code..."
git pull origin main

# Step 2: Install dependencies
echo "Installing dependencies..."
npm install

# Step 3: Run tests
echo "Running tests..."
npm test

# Step 4: Build application
echo "Building application..."
npm run build

# Step 5: Restart service
echo "Restarting service..."
sudo systemctl restart myapp

echo "Deployment completed successfully!"
```

Make it executable:
```bash
chmod +x workflows/deploy.sh
```

## Advanced Features

Conductor supports advanced workflow features for complex automation scenarios:

### Parallel Execution
Run multiple steps simultaneously to reduce execution time:
```yaml
name: parallel-workflow
steps:
  - name: parallel-group
    type: parallel
    steps:
      - name: task-1
        command: echo "Running task 1"
      - name: task-2
        command: echo "Running task 2"
```

### Conditional Execution
Execute steps based on conditions:
```yaml
name: conditional-workflow
steps:
  - name: check-environment
    command: echo "$ENV" > /tmp/env.txt
  - name: production-task
    condition: '[ "$(cat /tmp/env.txt)" = "production" ]'
    command: echo "Running production task"
```

### Loop Processing
Process multiple items with the same steps:
```yaml
name: loop-workflow
loop:
  items:
    - { name: "server1", port: 80 }
    - { name: "server2", port: 8080 }
steps:
  - name: process-item
    command: echo "Processing {{item.name}} on port {{item.port}}"
```

### Workflow Chaining
Execute workflows in sequence with dependencies:
```yaml
name: chained-workflow
depends_on:
  - build
  - test
steps:
  - name: deploy
    command: echo "Deploying application"
```

### AI Integration
Connect workflows to AI services for intelligent decision-making:
```bash
#!/usr/bin/env bash
# AI-powered workflow
if [ -n "$OPENAI_API_KEY" ]; then
  # Use AI to analyze logs and make decisions
  curl -s -X POST "https://api.openai.com/v1/chat/completions" 
    -H "Authorization: Bearer $OPENAI_API_KEY" 
    -d '{"prompt": "Analyze these logs..."}'
fi
```

See `docs/advanced-features.md` for detailed implementation information.

## CLI Commands

### Help
Show help information:
```bash
./bin/conductor --help
./bin/conductor -h
```

### Version
Show version information:
```bash
./bin/conductor --version
./bin/conductor -v
```

### List
List all available workflows:
```bash
./bin/conductor list
```

### Run
Execute a workflow:
```bash
./bin/conductor run <workflow-name>
```

### Inspect
View the contents of a workflow:
```bash
./bin/conductor inspect <workflow-name>
```

## Logging

Conductor automatically logs all operations to daily rotated log files in the `logs/` directory. Log files are named with the pattern `conductor-YYYY-MM-DD.log`.

### Log Levels
The logging system supports multiple levels:
- **ERROR**: Critical errors that prevent workflow execution
- **WARN**: Warnings that don't stop execution but indicate potential issues
- **INFO**: Informational messages about workflow progress (default level)
- **DEBUG**: Detailed debugging information for troubleshooting

### Controlling Log Level
You can control the logging level by setting the `LOG_LEVEL` environment variable:

```bash
# Show only errors and warnings
LOG_LEVEL=WARN ./bin/conductor run workflow-name

# Show all messages including debug information
LOG_LEVEL=DEBUG ./bin/conductor run workflow-name

# Show only errors
LOG_LEVEL=ERROR ./bin/conductor run workflow-name
```

### Log File Rotation
Logs are automatically rotated daily. Each day gets its own log file, making it easy to find logs for specific dates.

## Project Structure

```
conductor/
├── bin/           # CLI entry point scripts
│   └── conductor
├── src/           # core bash scripts
│   ├── logging.sh
│   ├── workflow.sh
│   ├── helpers.sh
│   ├── cli.sh
│   └── advanced-workflow.sh
├── tests/         # unit and integration tests
│   ├── test_logging.sh
│   ├── test_cli.sh
│   ├── test_workflow.sh
│   └── test_advanced_workflow.sh
├── docs/          # documentation
│   ├── usage.md
│   └── advanced-features.md
├── workflows/     # workflow definitions
│   ├── build-and-test.yaml
│   ├── deploy.sh
│   ├── advanced-demo.sh
│   ├── parallel-example.yaml
│   ├── conditional-example.yaml
│   ├── loop-example.yaml
│   ├── chained-example.yaml
│   └── ai-example.sh
├── logs/          # log files (runtime generated)
├── Makefile       # for building, running tests, cleaning
├── VERSION        # version file
└── README.md
```

## Development

### Running Tests

```bash
# Run all tests
make test

# Run all tests with detailed output
make test-all

# Run advanced workflow tests only
make test-advanced
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

### Test-Driven Development
This project follows strict TDD principles:
1. Write tests first in the `tests/` directory
2. Run tests to confirm they fail (red phase)
3. Implement the minimal code to make tests pass (green phase)
4. Refactor if needed while keeping tests passing (refactor phase)

## Examples

### Example 1: CI/CD Pipeline
```yaml
# workflows/ci-cd.yaml
name: ci-cd-pipeline
description: Continuous integration and deployment pipeline
steps:
  - name: checkout
    command: git checkout main
  - name: pull
    command: git pull origin main
  - name: install-deps
    command: npm install
  - name: lint
    command: npm run lint
  - name: test
    command: npm test
  - name: build
    command: npm run build
  - name: deploy
    command: npm run deploy
```

Run with:
```bash
./bin/conductor run ci-cd
```

### Example 2: System Maintenance
```bash
#!/usr/bin/env bash
# workflows/maintenance.sh

echo "Starting system maintenance..."

# Update package lists
echo "Updating package lists..."
sudo apt update

# Upgrade packages
echo "Upgrading packages..."
sudo apt upgrade -y

# Clean package cache
echo "Cleaning package cache..."
sudo apt autoremove -y
sudo apt autoclean

# Check disk space
echo "Checking disk space..."
df -h

# Restart services
echo "Restarting services..."
sudo systemctl restart nginx
sudo systemctl restart postgresql

echo "System maintenance completed!"
```

Run with:
```bash
./bin/conductor run maintenance
```

### Example 3: Data Backup
```json
{
  "name": "data-backup",
  "description": "Backup critical data directories",
  "steps": [
    {
      "name": "timestamp",
      "command": "TIMESTAMP=$(date +%Y%m%d_%H%M%S)"
    },
    {
      "name": "create-backup-dir",
      "command": "mkdir -p /backups/$TIMESTAMP"
    },
    {
      "name": "backup-documents",
      "command": "tar -czf /backups/$TIMESTAMP/documents.tar.gz /home/user/Documents"
    },
    {
      "name": "backup-pictures",
      "command": "tar -czf /backups/$TIMESTAMP/pictures.tar.gz /home/user/Pictures"
    },
    {
      "name": "verify-backup",
      "command": "ls -la /backups/$TIMESTAMP/"
    }
  ]
}
```

Run with:
```bash
./bin/conductor run data-backup
```

## Use Cases

### 1. Software Development
- Automate build, test, and deployment processes
- Standardize development environment setup
- Implement code quality checks

### 2. System Administration
- Automate routine maintenance tasks
- Implement backup and recovery procedures
- Manage service deployments and updates

### 3. Data Science
- Create reproducible data processing pipelines
- Automate model training and evaluation
- Implement data validation workflows

### 4. DevOps
- Orchestrate container deployments
- Manage infrastructure provisioning
- Implement monitoring and alerting workflows

### 5. Personal Productivity
- Automate file organization
- Create backup routines
- Implement personal development workflows

## Benefits

### Reliability
With comprehensive testing and error handling, conductor ensures your workflows execute reliably every time.

### Transparency
Built-in logging provides complete visibility into workflow execution, making troubleshooting easy.

### Portability
Pure Bash implementation means conductor runs on any system with Bash, from Linux servers to macOS laptops.

### Maintainability
Modular design and comprehensive documentation make it easy to extend and customize conductor for your specific needs.

### Community
Open source and well-documented, conductor can be shared, improved, and extended by the community.

Start simplifying your workflows today with conductor!