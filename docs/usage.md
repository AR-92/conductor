# conductor Usage

## Overview

conductor is a CLI tool for orchestrating and running workflows with composable steps.

## Commands

### help

Show help information:

```bash
conductor --help
conductor -h
```

### version

Show version information:

```bash
conductor --version
conductor -v
```

### list

List available workflows:

```bash
conductor list
```

### run

Run a workflow:

```bash
conductor run <workflow-name>
```

### inspect

Inspect a workflow:

```bash
conductor inspect <workflow-name>
```

## Workflow Files

Workflows can be defined as YAML/JSON files or shell scripts in the `workflows/` directory.

### YAML Workflow Example

Create a file `workflows/build-and-deploy.yaml`:

```yaml
name: build-and-deploy
steps:
  - name: build
    command: make build
  - name: test
    command: make test
  - name: deploy
    command: make deploy
```

### JSON Workflow Example

Create a file `workflows/build-and-deploy.json`:

```json
{
  "name": "build-and-deploy",
  "steps": [
    {
      "name": "build",
      "command": "make build"
    },
    {
      "name": "test",
      "command": "make test"
    },
    {
      "name": "deploy",
      "command": "make deploy"
    }
  ]
}
```

### Shell Script Workflow Example

Create a file `workflows/deploy.sh`:

```bash
#!/usr/bin/env bash
# Deploy workflow

echo "Starting deployment process..."
# Add your deployment commands here
echo "Deployment completed!"
```

Make sure to make the script executable:

```bash
chmod +x workflows/deploy.sh
```

## Logging

conductor automatically logs all operations to daily rotated log files in the `logs/` directory. Log files are named with the pattern `conductor-YYYY-MM-DD.log`.

The logging system supports multiple levels:
- ERROR: Critical errors
- WARN: Warnings
- INFO: Informational messages (default)
- DEBUG: Debug information

You can control the logging level by setting the `LOG_LEVEL` environment variable:

```bash
LOG_LEVEL=DEBUG ./bin/conductor run workflow-name
```