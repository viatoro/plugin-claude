#!/bin/bash
# Pre-push validation hook for trunk-based development
# Fires on PreToolUse for Bash commands — only acts on "git push" to main.
#
# This hook is the automated safety net that replaces PR review gates.
# It reads the tool input from stdin (JSON) and checks if it's a git push.
#
# Exit 0 = allow, Exit 2 = block with message

set -euo pipefail

# Read tool input from stdin
INPUT=$(cat)

# Extract the command from the JSON input
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# Only intercept git push commands targeting main
if ! echo "$COMMAND" | grep -q "git push"; then
  exit 0
fi

# Check if we're on main
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [ "$BRANCH" != "main" ]; then
  exit 0
fi

# Skip if SKIP_PRE_PUSH is set (escape hatch)
if [ "${SKIP_PRE_PUSH:-}" = "1" ]; then
  echo "⚠️  Pre-push validation skipped (SKIP_PRE_PUSH=1)"
  exit 0
fi

# Detect package manager
RUNNER=""
if [ -f "bun.lockb" ]; then
  RUNNER="bun"
elif [ -f "pnpm-lock.yaml" ]; then
  RUNNER="pnpm"
elif [ -f "yarn.lock" ]; then
  RUNNER="yarn"
elif [ -f "package-lock.json" ]; then
  RUNNER="npm"
elif [ -f "Cargo.toml" ]; then
  RUNNER="cargo"
elif [ -f "go.mod" ]; then
  RUNNER="go"
fi

# No recognized project — allow push
if [ -z "$RUNNER" ]; then
  exit 0
fi

FAILED=0

# Type check
if [ "$RUNNER" = "cargo" ]; then
  cargo check 2>&1 || FAILED=1
elif [ "$RUNNER" = "go" ]; then
  go vet ./... 2>&1 || FAILED=1
elif [ -f "package.json" ]; then
  if grep -q '"type-check"\|"typecheck"' package.json 2>/dev/null; then
    $RUNNER run type-check 2>&1 || $RUNNER run typecheck 2>&1 || FAILED=1
  fi
fi

# Lint
if [ "$RUNNER" = "cargo" ]; then
  cargo clippy 2>&1 || FAILED=1
elif [ -f "package.json" ]; then
  if grep -q '"lint"' package.json 2>/dev/null; then
    $RUNNER run lint 2>&1 || FAILED=1
  fi
fi

# Tests
if [ "$RUNNER" = "cargo" ]; then
  cargo test 2>&1 || FAILED=1
elif [ "$RUNNER" = "go" ]; then
  go test ./... 2>&1 || FAILED=1
elif [ -f "package.json" ]; then
  if grep -q '"test"' package.json 2>/dev/null; then
    $RUNNER test 2>&1 || FAILED=1
  fi
fi

if [ $FAILED -ne 0 ]; then
  echo "❌ Pre-push validation failed. Fix issues before pushing."
  echo "   To bypass: set SKIP_PRE_PUSH=1"
  exit 2
fi

exit 0
