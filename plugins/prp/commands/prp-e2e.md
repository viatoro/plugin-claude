---
description: Generate and run E2E tests with multi-action user flows. Supports interactive MCP verification.
argument-hint: "<flow-description|test-file|url> [--run] [--smoke] [--verify]"
---

# E2E Test Generator

**Input**: $ARGUMENTS

---

## Your Mission

Generate comprehensive E2E tests with multi-action user flows, or run existing ones.

**Core Philosophy**: E2E tests should mirror real user journeys — not test individual buttons, but complete flows from start to finish. Every test should answer: "Can the user actually do this?"

**Golden Rule**: Each test follows Setup → Action → Assert → Action → Assert → ... → Cleanup.

---

## Phase 0: DETECT - Environment

### 0.1 Detect E2E Framework

```bash
ls playwright.config.* cypress.config.* 2>/dev/null
ls -d e2e/ cypress/ tests/e2e/ 2>/dev/null
grep -E '"playwright"|"cypress"|"@playwright"' package.json 2>/dev/null
```

| Found | Framework | Config |
|-------|-----------|--------|
| `playwright.config.*` | Playwright | Read config |
| `cypress.config.*` | Cypress | Read config |
| Neither | Suggest setup | Help install |

### 0.2 Detect App Type

```bash
# Check for web framework
grep -E '"nuxt"|"next"|"vue"|"react"|"angular"|"svelte"' package.json 2>/dev/null

# Check for API framework
grep -E '"express"|"fastify"|"hono"|"nitro"' package.json 2>/dev/null

# Check base URL
grep -E 'baseURL|baseUrl' playwright.config.* cypress.config.* 2>/dev/null
```

### 0.3 Find Existing Tests

```bash
find . -name "*.spec.ts" -o -name "*.spec.js" -o -name "*.cy.ts" -o -name "*.cy.js" | head -20
```

**PHASE_0_CHECKPOINT:**

- [ ] Framework detected
- [ ] App type identified
- [ ] Existing test patterns found

---

## Phase 1: PARSE - Understand the Request

### 1.1 Determine Mode

| Input | Mode |
|-------|------|
| Flow description ("user checkout flow") | **Generate** new test |
| Test file path (`e2e/flows/auth.spec.ts`) | **Run** existing test |
| URL (`http://localhost:3000`) | **Interactive verify** via MCP |
| `--run` flag | Run all E2E tests |
| `--smoke` flag | Run smoke tests only |
| `--verify` flag | Verify generated test interactively via MCP |
| Blank | Show existing tests, suggest next |

### 1.2 For Generate Mode

Analyze the flow description:
- What user journey does this cover?
- What pages/routes are involved?
- What data is created/modified/deleted?
- What are the happy path steps?
- What error cases matter?

### 1.3 Gather Codebase Context

```bash
# Find relevant pages/routes
find . -path "*/pages/*" -o -path "*/routes/*" -o -path "*/views/*" | head -20

# Find existing selectors/test-ids
grep -r "data-testid" --include="*.vue" --include="*.tsx" --include="*.jsx" -l | head -10

# Find API endpoints
grep -rn "router\.\|app\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js" -l | head -10
```

Read the relevant source files to understand:
- Available `data-testid` attributes
- Page structure and navigation
- API endpoints for setup/cleanup
- Auth mechanism

**PHASE_1_CHECKPOINT:**

- [ ] Mode determined
- [ ] Flow steps mapped
- [ ] Source code reviewed for selectors

---

## Phase 2: GENERATE - Write the Test

### 2.1 Create File Structure (Page Object Model)

```
e2e/
├── tests/{flow-name}.spec.ts      # Test spec (short, readable)
├── pages/{page-name}.page.ts      # Page selectors + interactions
├── actions/{domain}.actions.ts    # Multi-page business flows
└── fixtures/test.fixture.ts       # Auth + page/action injection
```

### 2.2 Structure

Generate in this order:

1. **Pages** — one per UI page involved (selectors + single-page actions)
2. **Actions** — reusable business flows combining multiple pages
3. **Fixtures** — extend base test with pages/actions/auth
4. **Test spec** — short, reads like a user story
5. **cleanup** — afterEach via API if data created

### 2.3 Multi-Action Pattern

Each test should chain 3-7 distinct user actions:

```
Action 1: Navigate / Setup context
  → Assert: correct page/state
Action 2: Create / Input data
  → Assert: data visible/saved
Action 3: Modify / Update
  → Assert: changes reflected
Action 4: Secondary action (filter/sort/share)
  → Assert: expected behavior
Action 5: Cleanup / Delete
  → Assert: clean state
```

### 2.4 Rules

**DO:**
- Use `data-testid` selectors (check source for existing ones)
- Wait for specific elements, not arbitrary timeouts
- Include assertions after every action
- Test the complete flow, not individual steps
- Use API calls for setup/cleanup (faster than UI)
- Add comments marking each action step

**DON'T:**
- Use `waitForTimeout()` / `cy.wait(N)`
- Use CSS class selectors
- Create tests that depend on other tests' state
- Test implementation details (internal state, store)
- Hardcode environment-specific URLs

### 2.5 File Creation Order

```bash
mkdir -p e2e/tests e2e/pages e2e/actions e2e/fixtures
```

1. Create `e2e/pages/*.page.ts` — one per page, selectors only
2. Create `e2e/actions/*.actions.ts` — combine pages into flows
3. Create `e2e/fixtures/test.fixture.ts` — inject pages/actions/auth
4. Create `e2e/tests/{flow-name}.spec.ts` — short test using fixtures

**PHASE_2_CHECKPOINT:**

- [ ] Page objects created (selectors from actual source)
- [ ] Actions created (reusable business flows)
- [ ] Fixture extends base test with pages/actions
- [ ] Test spec is short — reads like a user story
- [ ] No selectors in test spec (all in pages)
- [ ] Setup/cleanup via API (not UI)

---

## Phase 3: VERIFY INTERACTIVELY - MCP Live Verification

**This phase runs when `--verify` is passed, a URL is provided, or after generating tests.**

Use Playwright MCP or Chrome DevTools MCP to walk through each test step in a real browser and verify it works before committing the test file.

### 3.1 Choose MCP Tool

| Available MCP | Use |
|---------------|-----|
| `playwright` | Preferred — built for testing, has snapshot |
| `chrome-devtools` | Alternative — works with any running Chrome |

### 3.2 Interactive Verification Loop

For EACH action in the generated test, follow this cycle:

```
┌─ STEP: Perform the action
│   → Use MCP tool (navigate, click, fill, etc.)
│
├─ SNAPSHOT: Capture page state
│   → browser_snapshot (Playwright) or take_snapshot (DevTools)
│   → Read the accessibility tree / DOM
│
├─ VERIFY: Check the assertion matches reality
│   → Does the expected element exist?
│   → Does it have the expected text/state?
│   → Is the URL correct?
│
├─ SCREENSHOT: Visual proof (optional)
│   → browser_take_screenshot / take_screenshot
│
├─ FIX: If verification fails
│   → Update selector in test file
│   → Adjust wait strategy
│   → Fix assertion value
│
└─ NEXT: Move to next action
```

### 3.3 Playwright MCP Step-by-Step

```
Step 1: Navigate
  → browser_navigate url="{base-url}"
  → browser_snapshot
  → VERIFY: page loaded, expected elements visible

Step 2: Login (if needed)
  → browser_fill selector="[data-testid='email']" value="test@example.com"
  → browser_fill selector="[data-testid='password']" value="password123"
  → browser_click selector="[data-testid='login-button']"
  → browser_snapshot
  → VERIFY: redirected to dashboard, user menu visible

Step 3: Navigate to feature
  → browser_click selector="[data-testid='nav-feature']"
  → browser_snapshot
  → VERIFY: feature page loaded, content visible

Step 4: Create item
  → browser_click selector="[data-testid='create-button']"
  → browser_fill selector="[data-testid='name-input']" value="Test Item"
  → browser_click selector="[data-testid='save-button']"
  → browser_snapshot
  → VERIFY: item appears in list, success toast shown

Step 5: Verify persistence
  → browser_navigate url="{base-url}/feature"  (reload)
  → browser_snapshot
  → VERIFY: item still visible after reload

Step 6: Delete item
  → browser_click selector="[data-testid='delete-button']"
  → browser_click selector="[data-testid='confirm-delete']"
  → browser_snapshot
  → VERIFY: item gone, empty state or updated list
```

### 3.4 Chrome DevTools MCP Step-by-Step

```
Step 1: Navigate
  → navigate_page url="{base-url}"
  → take_snapshot
  → VERIFY: page structure correct

Step 2: Interact
  → click selector="[data-testid='button']"
  → take_snapshot
  → VERIFY: expected change happened

Step 3: Fill form
  → fill selector="[data-testid='input']" value="test data"
  → click selector="[data-testid='submit']"
  → take_snapshot
  → VERIFY: form submitted, response visible

Step 4: Check state via JS
  → evaluate_script expression="document.querySelectorAll('[data-testid=item]').length"
  → VERIFY: count matches expected

Step 5: Visual check
  → take_screenshot
  → VERIFY: layout correct, no visual regressions
```

### 3.5 Verification Report

After walking through all steps, build a verification table:

```markdown
### Interactive Verification Results

| # | Action | MCP Tool Used | Selector | Result | Notes |
|---|--------|--------------|----------|--------|-------|
| 1 | Navigate to /login | browser_navigate | - | ✅ | Page loads in ~200ms |
| 2 | Fill email | browser_fill | [data-testid="email"] | ✅ | |
| 3 | Fill password | browser_fill | [data-testid="password"] | ✅ | |
| 4 | Click login | browser_click | [data-testid="login-button"] | ✅ | Redirects to /dashboard |
| 5 | Verify dashboard | browser_snapshot | - | ✅ | User menu visible |
| 6 | Click create | browser_click | [data-testid="create"] | ❌ → ✅ | Selector was wrong, fixed to [data-testid="new-item"] |
| 7 | Fill form | browser_fill | [data-testid="name"] | ✅ | |
| 8 | Save | browser_click | [data-testid="save"] | ✅ | Toast appears |
| 9 | Verify in list | browser_snapshot | [data-testid="item-card"] | ✅ | Item visible |
| 10 | Delete | browser_click | [data-testid="delete"] | ✅ | Confirmation dialog works |
```

### 3.6 Update Test File from Verification

If any selectors or assertions were wrong during verification:

1. Update the test file with corrected selectors
2. Add any missing waits discovered during live testing
3. Note timing-sensitive steps that need explicit waits

**PHASE_3_CHECKPOINT:**

- [ ] Every action verified via MCP
- [ ] All selectors confirmed to exist in live app
- [ ] Test file updated with any corrections
- [ ] Verification report generated

---

## Phase 4: RUN - Execute Test Suite

### 4.1 Run the Generated Test

**Playwright:**
```bash
npx playwright test e2e/flows/{flow-name}.spec.ts --reporter=list
```

**Cypress:**
```bash
npx cypress run --spec "cypress/e2e/{flow-name}.cy.ts"
```

### 4.2 Handle Failures

| Failure Type | Fix |
|-------------|-----|
| Element not found | Check selector, add wait |
| Timeout | Increase timeout or fix selector |
| Navigation error | Check URL, add waitForURL |
| Auth failure | Fix login helper/credentials |
| Flaky (passes sometimes) | Add proper waits, remove race conditions |

### 4.3 Iterate

1. Read failure output
2. Fix the test (not the app, unless it's a real bug)
3. Re-run
4. Repeat until green

**PHASE_4_CHECKPOINT:**

- [ ] Tests run successfully
- [ ] No flaky behavior
- [ ] All assertions pass

---

## Phase 5: OUTPUT - Report

```markdown
## E2E Tests Generated

**Flow**: {flow description}
**Framework**: {Playwright/Cypress}
**File**: `e2e/flows/{name}.spec.ts`

### Test Scenarios

| # | Test | Actions | Status |
|---|------|---------|--------|
| 1 | {test name} | {N} actions | ✅ Pass |
| 2 | {test name} | {N} actions | ✅ Pass |

### Actions Covered

1. {Action 1 description}
2. {Action 2 description}
3. {Action 3 description}
...

### Helpers Created

| File | Purpose |
|------|---------|
| `e2e/support/auth.ts` | Login/logout helpers |
| `e2e/fixtures/data.json` | Test seed data |

### Interactive Verification

{If --verify was used, include the verification table from Phase 3}

| # | Action | Selector | Result |
|---|--------|----------|--------|
| 1 | {action} | {selector} | ✅/❌→✅ |

**Selectors corrected during verification**: {count}
**Timing issues found**: {count}

### Run Commands

```bash
# Run this test
{run command}

# Run all E2E tests
{run all command}

# Run with UI
{headed command}

# Verify interactively
/prp:prp-e2e {test-file} --verify
```

### Next Steps

- Add error flow tests (invalid input, network failure)
- Add mobile viewport tests
- Add to CI pipeline
```

---

## Handling Edge Cases

### No E2E framework installed

Suggest Playwright setup:
```bash
npm init playwright@latest
```

### No data-testid in source code

1. Warn that selectors will be fragile
2. Use ARIA roles and text content as fallback
3. Suggest adding data-testid attributes

### App requires running server

```bash
# Check if dev server script exists
grep '"dev"\|"start"' package.json

# Playwright can auto-start server via webServer config
```

### Tests need seed data

Create API-based seeding:
```typescript
test.beforeEach(async ({ request }) => {
  await request.post('/api/test/seed', { data: seedData });
});
```

---

## Usage Examples

```bash
# Generate E2E test for a user flow
/prp:prp-e2e "user registration and onboarding flow"

# Generate + verify interactively via MCP
/prp:prp-e2e "admin creates product, customer purchases it" --verify

# Interactive exploration of live app (discover selectors, test flow)
/prp:prp-e2e http://localhost:3000

# Verify existing test file works step-by-step
/prp:prp-e2e e2e/flows/checkout.spec.ts --verify

# Run all E2E tests
/prp:prp-e2e --run

# Run smoke tests
/prp:prp-e2e --smoke

# Run specific test file
/prp:prp-e2e e2e/flows/checkout.spec.ts
```

---

## Success Criteria

- **FLOW_MAPPED**: User journey broken into 3-7 actions
- **TEST_GENERATED**: File created with multi-action tests
- **SELECTORS_VALID**: Using data-testid or ARIA from actual source
- **TESTS_PASS**: All tests green
- **ISOLATED**: No test depends on another test's state
- **NO_FLAKE**: No arbitrary waits or race conditions
