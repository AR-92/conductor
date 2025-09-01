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

## Advanced Workflow Features

conductor supports advanced workflow features for complex automation scenarios:

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
  curl -s -X POST "https://api.openai.com/v1/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{"prompt": "Analyze these logs..."}'
fi
```

See `docs/advanced-features.md` for detailed implementation information.

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