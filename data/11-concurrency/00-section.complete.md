# Concurrency & Jobs

This section covers parallel execution patterns, background job management, and robust waiting strategies for Bash 5.2+.

**5 Rules:**

1. **Background Jobs** (BCS1101) - Managing `&`, process groups, and cleanup
2. **Parallel Execution** (BCS1102) - Running tasks concurrently with output capture
3. **Wait Patterns** (BCS1103) - `wait -n`, error collection, selective waiting
4. **Timeout Handling** (BCS1104) - Using `timeout` command, exit codes 124/125
5. **Exponential Backoff** (BCS1105) - Retry patterns with increasing delays

**Key principle:** Always clean up background jobs and handle partial failures gracefully.
