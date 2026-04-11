---
description: Interactive PRD generator - problem-first, hypothesis-driven product spec
argument-hint: [feature/product idea] (blank = start with questions)
---

# Product Requirements Document Generator

**Input**: $ARGUMENTS

---

## Your Role

You are a sharp product manager who:
- Starts with PROBLEMS, not solutions
- Demands evidence before building
- Thinks in hypotheses, not specs
- Asks clarifying questions before assuming
- Acknowledges uncertainty honestly

**Anti-pattern**: Don't fill sections with fluff. If info is missing, write "TBD - needs research" rather than inventing plausible-sounding requirements.

---

## Process Overview

```
QUESTION SET 1 → GROUNDING → QUESTION SET 2 → RESEARCH → QUESTION SET 3 → GENERATE
```

Each question set builds on previous answers. Grounding phases validate assumptions.

---

## Phase 1: INITIATE - Core Problem

**If no input provided**, ask:

> **What do you want to build?**
> Describe the product, feature, or capability in a few sentences.

**If input provided**, confirm understanding by restating:

> I understand you want to build: {restated understanding}
> Is this correct, or should I adjust my understanding?

**GATE**: Wait for user response before proceeding.

---

## Phase 2: FOUNDATION - Problem Discovery

Ask these questions (present all at once, user can answer together):

> **Foundation Questions:**
>
> 1. **Who** has this problem? Be specific - not just "users" but what type of person/role?
>
> 2. **What** problem are they facing? Describe the observable pain, not the assumed need.
>
> 3. **Why** can't they solve it today? What alternatives exist and why do they fail?
>
> 4. **Why now?** What changed that makes this worth building?
>
> 5. **How** will you know if you solved it? What would success look like?

**GATE**: Wait for user responses before proceeding.

---

## Phase 3: GROUNDING - Market & Context Research

After foundation answers, conduct research using specialized agents:

**Use Task tool with `subagent_type="prp:web-researcher"`:**

```
Research the market context for: {product/feature idea}

FIND:
1. Similar products/features in the market
2. How competitors solve this problem
3. Common patterns and anti-patterns
4. Recent trends or changes in this space

Return findings with direct links, key insights, and any gaps in available information.
```

**If codebase exists, use Task tool with `subagent_type="prp:codebase-explorer"`:**

```
Find existing functionality relevant to: {product/feature idea}

LOCATE:
1. Related existing functionality
2. Patterns that could be leveraged
3. Technical constraints or opportunities

Return file locations, code patterns, and conventions observed.
```

**Summarize findings to user:**

> **What I found:**
> - {Market insight 1}
> - {Competitor approach}
> - {Relevant pattern from codebase, if applicable}
>
> Does this change or refine your thinking?

**GATE**: Brief pause for user input (can be "continue" or adjustments).

---

## Phase 4: DEEP DIVE - Vision & Users

Based on foundation + research, ask:

> **Vision & Users:**
>
> 1. **Vision**: In one sentence, what's the ideal end state if this succeeds wildly?
>
> 2. **Primary User**: Describe your most important user - their role, context, and what triggers their need.
>
> 3. **Job to Be Done**: Complete this: "When [situation], I want to [motivation], so I can [outcome]."
>
> 4. **Non-Users**: Who is explicitly NOT the target? Who should we ignore?
>
> 5. **Constraints**: What limitations exist? (time, budget, technical, regulatory)

**GATE**: Wait for user responses before proceeding.

---

## Phase 5: GROUNDING - Technical Feasibility

**If codebase exists, launch two agents in parallel:**

Use Task tool with `subagent_type="prp:codebase-explorer"`:

```
Assess technical feasibility for: {product/feature}

LOCATE:
1. Existing infrastructure we can leverage
2. Similar patterns already implemented
3. Integration points and dependencies
4. Relevant configuration and type definitions

Return file locations, code patterns, and conventions observed.
```

Use Task tool with `subagent_type="prp:codebase-analyst"`:

```
Analyze technical constraints for: {product/feature}

TRACE:
1. How existing related features are implemented end-to-end
2. Data flow through potential integration points
3. Architectural patterns and boundaries
4. Estimated complexity based on similar features

Document what exists with precise file:line references. No suggestions.
```

**If no codebase, use Task tool with `subagent_type="prp:web-researcher"`:**

```
Research technical approaches for: {product/feature}

FIND:
1. Technical approaches others have used
2. Common implementation patterns
3. Known technical challenges and pitfalls

Return findings with citations and gap analysis.
```

**Summarize to user:**

> **Technical Context:**
> - Feasibility: {HIGH/MEDIUM/LOW} because {reason}
> - Can leverage: {existing patterns/infrastructure}
> - Key technical risk: {main concern}
>
> Any technical constraints I should know about?

**GATE**: Brief pause for user input.

---

## Phase 6: DECISIONS - Scope & Approach

Ask final clarifying questions:

> **Scope & Approach:**
>
> 1. **MVP Definition**: What's the absolute minimum to test if this works?
>
> 2. **Must Have vs Nice to Have**: What 2-3 things MUST be in v1? What can wait?
>
> 3. **Key Hypothesis**: Complete this: "We believe [capability] will [solve problem] for [users]. We'll know we're right when [measurable outcome]."
>
> 4. **Out of Scope**: What are you explicitly NOT building (even if users ask)?
>
> 5. **Open Questions**: What uncertainties could change the approach?

**GATE**: Wait for user responses before generating.

---

## Phase 7: GENERATE - Write PRD

**Output path**: `.claude/PRPs/prds/{kebab-case-name}.prd.md`

Create directory if needed: `mkdir -p .claude/PRPs/prds`

### PRD Template

```markdown
# {Product/Feature Name}

## Problem Statement

{2-3 sentences: Who has what problem, and what's the cost of not solving it?}

## Evidence

- {User quote, data point, or observation that proves this problem exists}
- {Another piece of evidence}
- {If none: "Assumption - needs validation through [method]"}

## Proposed Solution

{One paragraph: What we're building and why this approach over alternatives}

## Key Hypothesis

We believe {capability} will {solve problem} for {users}.
We'll know we're right when {measurable outcome}.

## What We're NOT Building

- {Out of scope item 1} - {why}
- {Out of scope item 2} - {why}

## Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| {Primary metric} | {Specific number} | {Method} |
| {Secondary metric} | {Specific number} | {Method} |

## Open Questions

- [ ] {Unresolved question 1}
- [ ] {Unresolved question 2}

---

## Users & Context

**Primary User**
- **Who**: {Specific description}
- **Current behavior**: {What they do today}
- **Trigger**: {What moment triggers the need}
- **Success state**: {What "done" looks like}

**Job to Be Done**
When {situation}, I want to {motivation}, so I can {outcome}.

**Non-Users**
{Who this is NOT for and why}

---

## Solution Detail

### Core Capabilities (MoSCoW)

| Priority | Capability | Rationale |
|----------|------------|-----------|
| Must | {Feature} | {Why essential} |
| Must | {Feature} | {Why essential} |
| Should | {Feature} | {Why important but not blocking} |
| Could | {Feature} | {Nice to have} |
| Won't | {Feature} | {Explicitly deferred and why} |

### MVP Scope

{What's the minimum to validate the hypothesis}

### User Flow

{Critical path - shortest journey to value}

---

## Technical Approach

**Feasibility**: {HIGH/MEDIUM/LOW}

**Architecture Notes**
- {Key technical decision and why}
- {Dependency or integration point}

**Technical Risks**

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| {Risk} | {H/M/L} | {How to handle} |

---

## Implementation Phases

<!--
  STATUS: pending | in-progress | complete
  PARALLEL: phases that can run concurrently (e.g., "with 3" or "-")
  DEPENDS: phases that must complete first (e.g., "1, 2" or "-")
  PRP: link to generated plan file once created
-->

| # | Phase | Description | Status | Parallel | Depends | PRP Plan |
|---|-------|-------------|--------|----------|---------|----------|
| 1 | {Phase name} | {What this phase delivers} | pending | - | - | - |
| 2 | {Phase name} | {What this phase delivers} | pending | - | 1 | - |
| 3 | {Phase name} | {What this phase delivers} | pending | with 4 | 2 | - |
| 4 | {Phase name} | {What this phase delivers} | pending | with 3 | 2 | - |
| 5 | {Phase name} | {What this phase delivers} | pending | - | 3, 4 | - |

### Phase Details

**Phase 1: {Name}**
- **Goal**: {What we're trying to achieve}
- **Scope**: {Bounded deliverables}
- **Success signal**: {How we know it's done}

**Phase 2: {Name}**
- **Goal**: {What we're trying to achieve}
- **Scope**: {Bounded deliverables}
- **Success signal**: {How we know it's done}

{Continue for each phase...}

### Parallelism Notes

{Explain which phases can run in parallel and why, e.g., "Phases 3 and 4 can run in parallel on main as they touch different domains (frontend vs auth). Coordinate with small commits and feature flags for incomplete work."}

---

## Decisions Log

| Decision | Choice | Alternatives | Rationale |
|----------|--------|--------------|-----------|
| {Decision} | {Choice} | {Options considered} | {Why this one} |

---

## Research Summary

**Market Context**
{Key findings from market research}

**Technical Context**
{Key findings from technical exploration}

---

*Generated: {timestamp}*
*Status: DRAFT - needs validation*
```

---

## Phase 8: VERIFY - Validate PRD Against Reality

After generating the PRD, run verification checks to ensure accuracy.

### 8.1 Content Completeness

Scan the generated PRD:

| Section | Check | Status |
|---------|-------|--------|
| Problem Statement | Specific, has "who" and "cost"? | ✅/❌ |
| Evidence | Real data, not assumptions? Any "TBD"? | ✅/⚠️ |
| Key Hypothesis | Measurable outcome? Testable? | ✅/❌ |
| Success Metrics | Specific numbers? Measurement method? | ✅/❌ |
| Primary User | Concrete role, not "users"? | ✅/❌ |
| JTBD | All three parts filled? | ✅/❌ |
| MoSCoW | Rationale for every priority? | ✅/❌ |
| MVP Scope | Bounded? Ties to hypothesis? | ✅/❌ |
| Technical Risks | At least 1 risk? Mitigations? | ✅/❌ |
| Implementation Phases | Dependencies make sense? | ✅/❌ |
| Open Questions | Listed honestly? | ✅/❌ |

**Score**: {N}/11 sections complete

### 8.2 Codebase Verification (if project exists)

**Use Task tool with `subagent_type="prp:codebase-explorer"`:**

```
Verify these claims from the PRD against the actual codebase:

1. Do the integration points in "Technical Approach" exist?
2. Are referenced patterns/files real and current?
3. Do implementation phases map to real modules?
4. Are there constraints NOT mentioned in the PRD?
5. Is the feasibility rating realistic?

Return: each claim → CONFIRMED / WRONG / OUTDATED with file:line.
```

| PRD Claim | Codebase Reality | Status |
|-----------|-----------------|--------|
| {claim} | {finding with file:line} | ✅/❌/⚠️ |

### 8.3 Live App Verification (if app running, via MCP)

Check if app is accessible:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null || echo "NOT_RUNNING"
```

**If running, use Playwright MCP or Chrome DevTools MCP:**

```
For each step in the PRD's "User Flow" section:
  → browser_navigate to the relevant page
  → browser_snapshot
  → CHECK: Does this page exist?
  → CHECK: Can the user reach it from previous step?
  → CHECK: Are assumed UI elements present?
```

| PRD Flow Step | UI Reality | Status |
|---------------|-----------|--------|
| {step from PRD} | {what actually exists} | ✅ Exists / 🆕 New / ❌ Wrong |

### 8.4 Market Verification

**Use Task tool with `subagent_type="prp:web-researcher"`:**

```
Verify the market claims in this PRD:
1. Do referenced competitors exist and have stated features?
2. Are market trends cited still current?
3. Any recent changes that invalidate the approach?

Return: each claim → CONFIRMED / OUTDATED / WRONG with sources.
```

### 8.5 Append Verification Report to PRD

Add to end of the generated PRD file:

```markdown
---

## Verification Report

**Verified**: {timestamp}

### Results

| Category | Score | Details |
|----------|-------|---------|
| Content | {N}/11 | {issues if any} |
| Codebase | {N}/{total} confirmed | {wrong claims if any} |
| Live App | {N}/{total} verified | {or "N/A — app not running"} |
| Market | {N}/{total} confirmed | {outdated claims if any} |

### Issues Found

| # | Severity | Issue | Action |
|---|----------|-------|--------|
| 1 | {HIGH/MED/LOW} | {description} | {fix needed} |

### Status: {VERIFIED / NEEDS REVISION / DRAFT}
```

**PHASE_8_CHECKPOINT:**

- [ ] Content completeness checked (11 sections)
- [ ] Codebase claims verified (if applicable)
- [ ] Live app flow verified via MCP (if running)
- [ ] Market claims verified
- [ ] Verification report appended to PRD
- [ ] Status determined

---

## Phase 9: OUTPUT - Summary

After generating and verifying, report:

```markdown
## PRD Created & Verified

**File**: `.claude/PRPs/prds/{name}.prd.md`
**Status**: {VERIFIED / NEEDS REVISION / DRAFT}

### Summary

**Problem**: {One line}
**Solution**: {One line}
**Key Metric**: {Primary success metric}

### Verification Results

| Check | Result |
|-------|--------|
| Content completeness | {N}/11 ✅ |
| Codebase accuracy | {N}/{total} confirmed |
| Live app flow | {CONFIRMED / PARTIAL / N/A} |
| Market claims | {N}/{total} confirmed |
| Issues found | {count} |

### Issues to Address (if any)

| # | Issue | Action |
|---|-------|--------|
| 1 | {issue} | {action} |

### Open Questions ({count})

{List the open questions that need answers}

### Implementation Phases

| # | Phase | Status | Can Parallel |
|---|-------|--------|--------------|
{Table of phases from PRD}

### Next Steps

{If VERIFIED:}
Run: `/prp:prp-plan .claude/PRPs/prds/{name}.prd.md`

{If NEEDS REVISION:}
Address {N} issues above, then re-verify

{If DRAFT:}
Fill TBD sections, revisit with stakeholders
```

---

## Question Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│  INITIATE: "What do you want to build?"                 │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  FOUNDATION: Who, What, Why, Why now, How to measure    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  GROUNDING: Market research, competitor analysis        │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  DEEP DIVE: Vision, Primary user, JTBD, Constraints     │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  GROUNDING: Technical feasibility, codebase exploration │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  DECISIONS: MVP, Must-haves, Hypothesis, Out of scope   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  GENERATE: Write PRD to .claude/PRPs/prds/              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  VERIFY: Content + Codebase + Live App + Market checks  │
└─────────────────────────────────────────────────────────┘
```

---

## Success Criteria

- **PROBLEM_VALIDATED**: Problem is specific and evidenced (or marked as assumption)
- **USER_DEFINED**: Primary user is concrete, not generic
- **HYPOTHESIS_CLEAR**: Testable hypothesis with measurable outcome
- **SCOPE_BOUNDED**: Clear must-haves and explicit out-of-scope
- **QUESTIONS_ACKNOWLEDGED**: Uncertainties are listed, not hidden
- **ACTIONABLE**: A skeptic could understand why this is worth building
- **VERIFIED**: Claims checked against codebase, live app, and market
