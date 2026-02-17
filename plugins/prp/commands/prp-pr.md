---
description: DEPRECATED - Not used in trunk-based development workflow
argument-hint: (deprecated)
deprecated: true
---

# Create Pull Request (DEPRECATED)

⚠️ **This command is deprecated in trunk-based development workflows.**

---

## Trunk-Based Development

This project uses **trunk-based development**, where all work happens directly on the main branch. Pull requests are not part of this workflow.

**Instead of creating PRs:**

1. **Commit frequently** to main:
   ```bash
   git add .
   git commit -m "descriptive message"
   ```

2. **Push directly** to main:
   ```bash
   git push origin main
   ```

3. **Use feature flags** for incomplete work

**For code review**, use:
- Pre-push hooks for automated validation
- Pair programming
- Post-commit review tools

---

## Why No PRs?

Trunk-based development prioritizes:
- Continuous integration to main
- Small, atomic commits
- Faster feedback loops
- Reduced merge conflicts
- Simpler workflow

---

## Migration Guide

If you need to transition from PR-based workflow:

### Old Workflow (PR-based)
```bash
git checkout -b feature/my-feature
# make changes
git commit -m "Add feature"
git push -u origin feature/my-feature
gh pr create
```

### New Workflow (Trunk-based)
```bash
# Already on main
# make changes
git commit -m "Add feature (behind feature flag if incomplete)"
git push origin main
```

---

## Related Commands

For trunk-based development, use:
- `/prp:prp-commit` - Quick commit with natural language targeting
- `/prp:prp-implement` - Execute plans with automatic push to main
- `/prp:prp-ralph` - Autonomous implementation loops
