# PRP Core Plugin

Complete PRP (Product Requirement Prompt) workflow automation for Claude Code.

## Overview

This plugin provides a comprehensive workflow for creating, executing, and shipping features using the PRP methodology - where **PRP = PRD + curated codebase intelligence + agent/runbook** designed to enable AI agents to ship production-ready code on the first pass.

## Commands

### Core Workflow

| Command | Description |
|---------|-------------|
| `/prp:prp-prd` | Interactive PRD generator with implementation phases |
| `/prp:prp-plan` | Create implementation plan (from PRD or free-form input) |
| `/prp:prp-implement` | Execute a plan with validation loops |

### Issue Workflow

| Command | Description |
|---------|-------------|
| `/prp:prp-issue-investigate` | Analyze GitHub issue, create implementation plan |
| `/prp:prp-issue-fix` | Execute fix from investigation artifact |

### Git & Review (Trunk-Based)

| Command | Description |
|---------|-------------|
| `/prp:prp-commit` | Smart commit with natural language file targeting |
| `/prp:prp-push` | Validate and push to main (quality gate) |
| `/prp:prp-review` | Comprehensive commit code review |
| `/prp:prp-review-agents` | Multi-agent commit review (comments, tests, errors, types, code, docs, simplify) |

## Agents

Specialized agents for code analysis and review workflows.

### Codebase Analysis

| Agent | Description |
|-------|-------------|
| `codebase-analyst` | Documents HOW code works with file:line references |
| `codebase-explorer` | Finds WHERE code lives AND extracts patterns |
| `web-researcher` | Researches web for docs, APIs, best practices |

### Review Workflow

| Agent | Description |
|-------|-------------|
| `code-reviewer` | Project guidelines, bugs, type/module checks |
| `comment-analyzer` | Comment accuracy and maintainability |
| `test-analyzer` | Test coverage quality and gaps |
| `silent-failure-hunter` | Error handling and silent failures |
| `type-design-analyzer` | Type encapsulation and invariants |
| `code-simplifier` | Clarity and maintainability improvements |
| `docs-impact-agent` | Updates stale documentation |

### Using Agents

Agents are invoked automatically by `/prp:prp-review-agents` or manually via Task tool:

```
/prp:prp-review-agents                  # Full review of last commit
/prp:prp-review-agents abc123f          # Review specific commit
/prp:prp-review-agents HEAD~3..HEAD tests errors # Specific aspects only
```

## Workflow (Trunk-Based)

All work happens directly on main. No feature branches or PRs.

### Large Features: PRD → Plan → Implement → Review → Push

```
/prp:prp-prd "user authentication system"
    ↓
Creates PRD with Implementation Phases table
    ↓
/prp:prp-plan .claude/PRPs/prds/user-auth.prd.md
    ↓
Auto-selects next pending phase, creates plan
    ↓
/prp:prp-implement .claude/PRPs/plans/user-auth-phase-1.plan.md
    ↓
Executes plan on main, commits, archives plan
    ↓
/prp:prp-review-agents        # Optional: review before pushing
    ↓
/prp:prp-push                 # Validate and push to main
    ↓
Repeat /prp:prp-plan for next phase
```

### Medium Features: Direct to Plan

```
/prp:prp-plan "add pagination to the API"
    ↓
/prp:prp-implement .claude/PRPs/plans/add-pagination.plan.md
    ↓
/prp:prp-push                 # Validate and push
```

### Bug Fixes: Issue Workflow

```
/prp:prp-issue-investigate 123
    ↓
/prp:prp-issue-fix 123
    ↓
Commits and pushes fix directly to main
```

### Code Review: Pre-Push or Post-Commit

```
/prp:prp-review              # Review last commit
/prp:prp-review-agents       # Multi-agent review of last commit
    ↓
Fix issues in follow-up commits
    ↓
/prp:prp-push                # Validate and push
```

### Quality Gates

The pre-push hook automatically runs type-check, lint, and tests before any `git push` to main. This replaces PR review as the automated quality gate.

To bypass in emergencies: `SKIP_PRE_PUSH=1 git push`

## Installation

### Option 1: From GitHub (Recommended)

```bash
# Add marketplace from GitHub
/plugin marketplace add viatoro/plugin-claude

# Install plugin
/plugin install prp-core@prp-marketplace
```

### Option 2: Local Development/Testing

```bash
# Navigate to the repository root
cd /path/to/PRPs-agentic-eng

# Start Claude Code
claude

# Add local marketplace (use absolute path)
/plugin marketplace add /absolute/path/to/PRPs-agentic-eng

# Install plugin
/plugin install prp-core@prp-marketplace

# Restart Claude Code (required)
```

### Option 3: Team Automatic Installation

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "prp-marketplace": {
      "source": "viatoro/plugin-claude"
    }
  },
  "enabledPlugins": [
    "prp-core@prp-marketplace"
  ]
}
```

## Artifacts Structure

All artifacts are stored in `.claude/PRPs/`:

```
.claude/PRPs/
├── prds/              # Product requirement documents
├── plans/             # Implementation plans
│   └── completed/     # Archived completed plans
├── reports/           # Implementation reports
├── issues/            # Issue investigation artifacts
│   └── completed/     # Archived completed investigations
└── reviews/           # Code review reports
```

## PRD Phases

PRDs include an Implementation Phases table:

```markdown
| # | Phase | Description | Status | Parallel | Depends | PRP Plan |
|---|-------|-------------|--------|----------|---------|----------|
| 1 | Auth  | User login  | complete | -      | -       | [link]   |
| 2 | API   | Endpoints   | in-progress | -   | 1       | [link]   |
| 3 | UI    | Frontend    | pending | with 4  | 2       | -        |
```

- **Status**: `pending` → `in-progress` → `complete`
- **Parallel**: Phases that can run concurrently
- **Depends**: Phases that must complete first

## PRP Methodology

### What is a PRP?

**PRP = PRD + curated codebase intelligence + agent/runbook**

A PRP is a comprehensive implementation document containing:
1. **Context** - All necessary patterns, documentation, and examples
2. **Plan** - Step-by-step tasks with validation gates
3. **Validation** - Executable commands to verify correctness

### Core Principles

1. **Context is King** - Include ALL necessary information
2. **Validation Loops** - Provide executable tests the AI can run and fix
3. **Information Dense** - Use keywords and patterns from codebase
4. **Bounded Scope** - Each plan completable by AI in one loop

## Requirements

- Claude Code installed
- Git configured
- GitHub CLI (`gh`) for issue management

## Troubleshooting

### Plugin Not Loading

```bash
/plugin
/plugin uninstall prp-core@marketplace
/plugin install prp-core@marketplace
# Restart Claude Code
```

### Commands Not Found

Ensure Claude Code restarted after installation:

```bash
/help
```

## License

MIT License

## Support

- **Issues**: https://github.com/viatoro/plugin-claude/issues
- **Documentation**: https://github.com/viatoro/plugin-claude
