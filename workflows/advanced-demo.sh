#!/usr/bin/env bash
# workflows/advanced-demo.sh - Demonstration of advanced conductor features

echo "=== Advanced Conductor Features Demo ==="

# 1. Parallel Execution Example
echo "1. Parallel Execution Example"
echo "Starting three tasks in parallel..."
sleep 2 &
echo "Task 1 started" &
sleep 3 &
echo "Task 2 started" &
sleep 1 &
echo "Task 3 started" &

echo "Waiting for all tasks to complete..."
wait
echo "All parallel tasks completed!"

echo ""

# 2. Conditional Execution Example
echo "2. Conditional Execution Example"
ENVIRONMENT=${ENV:-"development"}

if [ "$ENVIRONMENT" = "production" ]; then
    echo "Running production-specific tasks..."
    echo "Deploying to production servers..."
else
    echo "Running development tasks..."
    echo "Starting development server..."
fi

echo ""

# 3. Loop Example
echo "3. Loop Example"
servers=("web01" "web02" "web03")

echo "Processing ${#servers[@]} servers:"
for server in "${servers[@]}"; do
    echo "  - Checking health of $server..."
    # Simulate health check
    sleep 0.5
    echo "  - $server is healthy"
done

echo ""

# 4. Chained Workflow Example
echo "4. Chained Workflow Example"
echo "Executing build workflow..."
echo "Build completed successfully"

echo "Executing test workflow..."
echo "All tests passed"

echo "Executing deploy workflow..."
echo "Deployment to staging environment completed"

echo ""

# 5. AI Integration Example (if API key is available)
echo "5. AI Integration Example"
if [ -n "${OPENAI_API_KEY:-}" ]; then
    echo "AI integration would analyze system logs and provide insights..."
    echo "Example AI analysis: 'System performance is optimal with no critical issues detected.'"
else
    echo "AI integration requires OPENAI_API_KEY environment variable"
    echo "Set it to enable AI-powered workflow decisions"
fi

echo ""
echo "=== Demo Completed ==="