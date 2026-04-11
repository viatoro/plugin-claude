---
name: prp-e2e
description: "Generate and run E2E tests with multi-action user flows. Auto-detects framework (Playwright/Cypress). Creates comprehensive test scenarios covering real user journeys with setup, actions, assertions, and cleanup."
user-invocable: false
---

# E2E Testing Framework Knowledge

This skill provides the patterns and knowledge needed to create production-grade E2E tests with multi-action user flows.

---

## 1. Framework Detection

### Auto-Detect E2E Framework

Check these files to determine the project's E2E setup:

| File/Dir | Framework | Runner |
|----------|-----------|--------|
| `playwright.config.ts` | Playwright | `npx playwright test` |
| `playwright.config.js` | Playwright | `npx playwright test` |
| `cypress.config.ts` | Cypress | `npx cypress run` |
| `cypress.config.js` | Cypress | `npx cypress run` |
| `cypress/` dir | Cypress | `npx cypress run` |
| `e2e/` dir | Check contents | varies |
| None found | Suggest Playwright | Setup needed |

### Check package.json for E2E scripts

```bash
grep -E '"e2e"|"test:e2e"|"playwright"|"cypress"' package.json
```

---

## 2. Test Structure: Multi-Action Patterns

### The Multi-Action Flow Pattern

Every E2E test should follow this structure:

```
Setup → Action 1 → Assert → Action 2 → Assert → ... → Cleanup → Final Assert
```

### Playwright Multi-Action Example

```typescript
import { test, expect } from '@playwright/test';

test.describe('Task Management Flow', () => {
  // ─── Setup: runs before each test ───
  test.beforeEach(async ({ page }) => {
    // Seed test data or login
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="login-button"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('create, edit, complete, and delete a task', async ({ page }) => {
    // ─── Action 1: Navigate to tasks ───
    await page.click('[data-testid="nav-tasks"]');
    await expect(page).toHaveURL('/tasks');
    await expect(page.locator('h1')).toHaveText('Tasks');

    // ─── Action 2: Create a new task ───
    await page.click('[data-testid="create-task"]');
    await page.fill('[data-testid="task-title"]', 'Write E2E tests');
    await page.fill('[data-testid="task-description"]', 'Cover all user flows');
    await page.selectOption('[data-testid="task-priority"]', 'high');
    await page.click('[data-testid="save-task"]');

    // Assert: task appears in list
    const taskCard = page.locator('[data-testid="task-card"]', {
      hasText: 'Write E2E tests',
    });
    await expect(taskCard).toBeVisible();
    await expect(taskCard.locator('.priority-badge')).toHaveText('High');

    // ─── Action 3: Edit the task ───
    await taskCard.click();
    await expect(page).toHaveURL(/\/tasks\/\d+/);
    await page.click('[data-testid="edit-task"]');
    await page.fill('[data-testid="task-title"]', 'Write comprehensive E2E tests');
    await page.click('[data-testid="save-task"]');

    // Assert: changes persisted
    await expect(page.locator('[data-testid="task-title-display"]')).toHaveText(
      'Write comprehensive E2E tests'
    );

    // ─── Action 4: Complete the task ───
    await page.click('[data-testid="complete-task"]');

    // Assert: task shows completed state
    await expect(page.locator('[data-testid="task-status"]')).toHaveText('Completed');
    await expect(page.locator('[data-testid="completed-at"]')).toBeVisible();

    // ─── Action 5: Delete the task ───
    await page.click('[data-testid="delete-task"]');

    // Handle confirmation dialog
    await page.click('[data-testid="confirm-delete"]');

    // Assert: redirected to list, task gone
    await expect(page).toHaveURL('/tasks');
    await expect(
      page.locator('[data-testid="task-card"]', { hasText: 'Write comprehensive E2E tests' })
    ).not.toBeVisible();
  });

  test('bulk actions on multiple tasks', async ({ page }) => {
    // ─── Action 1: Create multiple tasks ───
    const tasks = ['Task A', 'Task B', 'Task C'];
    for (const title of tasks) {
      await page.click('[data-testid="quick-add"]');
      await page.fill('[data-testid="quick-add-input"]', title);
      await page.press('[data-testid="quick-add-input"]', 'Enter');
    }

    // Assert: all tasks visible
    for (const title of tasks) {
      await expect(
        page.locator('[data-testid="task-card"]', { hasText: title })
      ).toBeVisible();
    }

    // ─── Action 2: Select all tasks ───
    await page.click('[data-testid="select-all"]');
    await expect(page.locator('[data-testid="selected-count"]')).toHaveText('3 selected');

    // ─── Action 3: Bulk complete ───
    await page.click('[data-testid="bulk-complete"]');

    // Assert: all marked complete
    const completedBadges = page.locator('[data-testid="task-status"]:has-text("Completed")');
    await expect(completedBadges).toHaveCount(3);

    // ─── Action 4: Filter to show only completed ───
    await page.click('[data-testid="filter-status"]');
    await page.click('[data-testid="filter-completed"]');

    // Assert: all 3 still visible
    await expect(page.locator('[data-testid="task-card"]')).toHaveCount(3);

    // ─── Action 5: Bulk delete ───
    await page.click('[data-testid="select-all"]');
    await page.click('[data-testid="bulk-delete"]');
    await page.click('[data-testid="confirm-delete"]');

    // Assert: empty state shown
    await expect(page.locator('[data-testid="empty-state"]')).toBeVisible();
  });
});
```

### Cypress Multi-Action Example

```typescript
describe('E-commerce Checkout Flow', () => {
  beforeEach(() => {
    cy.login('test@example.com', 'password123');
    cy.visit('/shop');
  });

  it('browse, add to cart, checkout, and verify order', () => {
    // ─── Action 1: Search and filter products ───
    cy.get('[data-testid="search-input"]').type('wireless headphones');
    cy.get('[data-testid="search-button"]').click();
    cy.get('[data-testid="product-card"]').should('have.length.greaterThan', 0);

    cy.get('[data-testid="filter-price-range"]').select('50-100');
    cy.get('[data-testid="product-card"]').should('have.length.greaterThan', 0);

    // ─── Action 2: Add item to cart ───
    cy.get('[data-testid="product-card"]').first().as('selectedProduct');
    cy.get('@selectedProduct').find('[data-testid="product-name"]').invoke('text').as('productName');
    cy.get('@selectedProduct').find('[data-testid="add-to-cart"]').click();

    // Assert: cart badge updates
    cy.get('[data-testid="cart-badge"]').should('contain', '1');

    // ─── Action 3: Add a second item with quantity ───
    cy.get('[data-testid="product-card"]').eq(1).find('[data-testid="add-to-cart"]').click();
    cy.get('[data-testid="cart-badge"]').should('contain', '2');

    // ─── Action 4: Open cart and modify quantities ───
    cy.get('[data-testid="cart-icon"]').click();
    cy.url().should('include', '/cart');
    cy.get('[data-testid="cart-item"]').should('have.length', 2);

    // Increase quantity of first item
    cy.get('[data-testid="cart-item"]').first()
      .find('[data-testid="quantity-increase"]').click();
    cy.get('[data-testid="cart-item"]').first()
      .find('[data-testid="quantity-value"]').should('have.text', '2');

    // ─── Action 5: Proceed to checkout ───
    cy.get('[data-testid="checkout-button"]').click();
    cy.url().should('include', '/checkout');

    // Fill shipping
    cy.get('[data-testid="shipping-name"]').type('John Doe');
    cy.get('[data-testid="shipping-address"]').type('123 Main St');
    cy.get('[data-testid="shipping-city"]').type('Portland');
    cy.get('[data-testid="shipping-zip"]').type('97201');

    // Fill payment
    cy.get('[data-testid="card-number"]').type('4242424242424242');
    cy.get('[data-testid="card-expiry"]').type('12/28');
    cy.get('[data-testid="card-cvc"]').type('123');

    // ─── Action 6: Place order ───
    cy.get('[data-testid="place-order"]').click();

    // Assert: order confirmation
    cy.url().should('include', '/order-confirmation');
    cy.get('[data-testid="order-number"]').should('exist');
    cy.get('[data-testid="order-status"]').should('contain', 'Confirmed');

    // ─── Action 7: Verify order in order history ───
    cy.get('[data-testid="nav-orders"]').click();
    cy.url().should('include', '/orders');
    cy.get('[data-testid="order-row"]').first()
      .should('contain', 'Confirmed');
  });
});
```

---

## 3. Multi-Action Pattern Library

### Pattern: CRUD Flow

```
Create → Read (verify) → Update → Read (verify changes) → Delete → Read (verify gone)
```

### Pattern: Auth Flow

```
Register → Verify email → Login → Access protected page → Logout → Verify redirected
```

### Pattern: Search & Filter

```
Load list → Search → Verify results → Add filter → Verify narrowed → Clear filters → Verify reset
```

### Pattern: Form Wizard

```
Step 1 (fill) → Next → Step 2 (fill) → Back → Verify Step 1 data → Next → Step 2 → Next → Step 3 → Submit → Verify
```

### Pattern: Real-time Updates

```
Open page in tab A → Make change in tab B → Verify update appears in tab A
```

### Pattern: Error Recovery

```
Submit invalid data → Verify error → Fix data → Resubmit → Verify success
```

### Pattern: Drag & Drop / Reorder

```
Load list → Drag item A above item B → Verify new order → Refresh page → Verify order persisted
```

### Pattern: Pagination & Infinite Scroll

```
Load page 1 → Verify items → Next page → Verify different items → Previous page → Verify original items
```

---

## 4. Test Organization

### File Structure

```
e2e/
├── fixtures/           # Test data and mocks
│   ├── users.json
│   └── products.json
├── support/            # Shared helpers
│   ├── auth.ts         # Login/logout helpers
│   ├── api.ts          # API seed/cleanup helpers
│   └── selectors.ts    # Shared selectors
├── flows/              # Multi-action flow tests
│   ├── auth.spec.ts
│   ├── checkout.spec.ts
│   ├── task-management.spec.ts
│   └── admin-panel.spec.ts
└── smoke/              # Quick critical-path tests
    └── smoke.spec.ts
```

### Naming Convention

```
{feature}.spec.ts         # Feature test
{feature}.{scenario}.ts   # Specific scenario
smoke.spec.ts             # Critical path only
```

---

## 5. Best Practices

### Selectors

| Priority | Selector | Example |
|----------|----------|---------|
| 1st | data-testid | `[data-testid="submit-btn"]` |
| 2nd | ARIA role | `role="button"` |
| 3rd | Text content | `text="Submit"` |
| Avoid | CSS class/ID | `.btn-primary`, `#submit` |

### Waiting Strategy

```typescript
// GOOD: wait for specific element
await expect(page.locator('[data-testid="result"]')).toBeVisible();

// GOOD: wait for network idle after action
await page.click('[data-testid="save"]');
await page.waitForResponse(resp => resp.url().includes('/api/save'));

// BAD: arbitrary timeout
await page.waitForTimeout(3000);
```

### Test Isolation

```typescript
// GOOD: each test seeds its own data
test.beforeEach(async ({ request }) => {
  await request.post('/api/test/seed', { data: { tasks: testTasks } });
});

test.afterEach(async ({ request }) => {
  await request.post('/api/test/cleanup');
});

// BAD: tests depend on each other's state
```

### Retry Strategy

```typescript
// playwright.config.ts
export default defineConfig({
  retries: process.env.CI ? 2 : 0,
  use: {
    actionTimeout: 10_000,
    navigationTimeout: 30_000,
  },
});
```

---

## 6. API + UI Hybrid Tests

For flows that combine API setup with UI verification:

```typescript
test('admin creates user via API, user logs in via UI', async ({ page, request }) => {
  // ─── Setup via API (fast) ───
  const response = await request.post('/api/admin/users', {
    data: {
      email: 'newuser@test.com',
      password: 'SecureP@ss1',
      role: 'editor',
    },
  });
  expect(response.ok()).toBeTruthy();
  const { id: userId } = await response.json();

  // ─── Action 1: Login as new user (UI) ───
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'newuser@test.com');
  await page.fill('[data-testid="password"]', 'SecureP@ss1');
  await page.click('[data-testid="login-button"]');
  await expect(page).toHaveURL('/dashboard');

  // ─── Action 2: Verify role permissions ───
  await page.click('[data-testid="nav-content"]');
  await expect(page.locator('[data-testid="edit-button"]')).toBeVisible();
  await expect(page.locator('[data-testid="delete-button"]')).not.toBeVisible(); // editors can't delete

  // ─── Action 3: Edit content ───
  await page.click('[data-testid="edit-button"]');
  await page.fill('[data-testid="content-body"]', 'Updated by editor');
  await page.click('[data-testid="save-content"]');
  await expect(page.locator('[data-testid="toast-success"]')).toBeVisible();

  // ─── Cleanup via API ───
  await request.delete(`/api/admin/users/${userId}`);
});
```

---

## 7. Multi-Tab / Multi-User Tests (Playwright)

```typescript
test('real-time collaboration between two users', async ({ browser }) => {
  // ─── Setup: Create two browser contexts (two users) ───
  const userAContext = await browser.newContext();
  const userBContext = await browser.newContext();
  const userAPage = await userAContext.newPage();
  const userBPage = await userBContext.newPage();

  // Login both users
  await loginAs(userAPage, 'alice@test.com');
  await loginAs(userBPage, 'bob@test.com');

  // ─── Action 1: Both navigate to shared document ───
  await userAPage.goto('/docs/shared-doc');
  await userBPage.goto('/docs/shared-doc');

  // ─── Action 2: User A types ───
  await userAPage.fill('[data-testid="editor"]', 'Hello from Alice');

  // ─── Action 3: User B sees the update ───
  await expect(userBPage.locator('[data-testid="editor"]')).toContainText('Hello from Alice');

  // ─── Action 4: User B adds text ───
  await userBPage.locator('[data-testid="editor"]').pressSequentially(' and Bob');

  // ─── Action 5: User A sees combined text ───
  await expect(userAPage.locator('[data-testid="editor"]')).toContainText(
    'Hello from Alice and Bob'
  );

  // Cleanup
  await userAContext.close();
  await userBContext.close();
});
```

---

## 8. Mobile / Responsive Tests (Playwright)

```typescript
test.describe('mobile checkout flow', () => {
  test.use({ viewport: { width: 375, height: 812 } }); // iPhone X

  test('complete purchase on mobile', async ({ page }) => {
    await page.goto('/shop');

    // ─── Action 1: Open mobile menu ───
    await page.click('[data-testid="hamburger-menu"]');
    await expect(page.locator('[data-testid="mobile-nav"]')).toBeVisible();

    // ─── Action 2: Navigate via mobile menu ───
    await page.click('[data-testid="mobile-nav-shop"]');
    await expect(page.locator('[data-testid="mobile-nav"]')).not.toBeVisible();

    // ─── Action 3: Swipe through products ───
    const carousel = page.locator('[data-testid="product-carousel"]');
    await carousel.evaluate(el => el.scrollLeft += 300);

    // ─── Action 4: Tap to add to cart ───
    await page.tap('[data-testid="product-card"] >> nth=2');
    await page.tap('[data-testid="add-to-cart"]');

    // ─── Action 5: Swipe up to see cart summary ───
    await page.locator('[data-testid="cart-drawer"]').swipe('up');
    await expect(page.locator('[data-testid="cart-total"]')).toBeVisible();
  });
});
```

---

## 9. Smoke Test Template

Quick critical-path test to run before every push:

```typescript
test.describe('Smoke Tests', () => {
  test('critical path: login → dashboard → key feature → logout', async ({ page }) => {
    // Can we reach the app?
    await page.goto('/');
    await expect(page).toHaveTitle(/App Name/);

    // Can we login?
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="login-button"]');
    await expect(page).toHaveURL('/dashboard');

    // Is the key feature working?
    await page.click('[data-testid="nav-main-feature"]');
    await expect(page.locator('[data-testid="feature-content"]')).toBeVisible();

    // Can we logout?
    await page.click('[data-testid="user-menu"]');
    await page.click('[data-testid="logout"]');
    await expect(page).toHaveURL('/login');
  });
});
```

---

## 10. Interactive MCP Verification

### Why Interactive Verification?

Generated tests often have wrong selectors or missing waits. Interactive verification catches these BEFORE the test file is committed — by walking through each step in a real browser via MCP.

### The Verify Loop

For every action in the test:

```
ACTION → SNAPSHOT → VERIFY → (FIX if wrong) → NEXT
```

### Playwright MCP Verification Pattern

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: NAVIGATE                                            │
│   Tool: browser_navigate                                    │
│   url: "http://localhost:3000/login"                        │
│                                                             │
│ Step 2: SNAPSHOT (see what's on screen)                     │
│   Tool: browser_snapshot                                    │
│   Returns: accessibility tree with all interactive elements │
│   → Read the tree to find correct selectors                 │
│   → Compare with selectors in test file                     │
│                                                             │
│ Step 3: ACT (perform the test action)                       │
│   Tool: browser_fill                                        │
│   selector: "[data-testid='email']"                         │
│   value: "test@example.com"                                 │
│                                                             │
│ Step 4: SNAPSHOT AGAIN (verify the action worked)           │
│   Tool: browser_snapshot                                    │
│   → Did the input get the value?                            │
│   → Did the page change as expected?                        │
│   → Any error messages appear?                              │
│                                                             │
│ Step 5: SCREENSHOT (visual proof)                           │
│   Tool: browser_take_screenshot                             │
│   → Save as evidence                                        │
│   → Check layout, no visual regressions                     │
│                                                             │
│ Step 6: FIX (if snapshot shows wrong state)                 │
│   → Update selector in test file                            │
│   → Add wait/retry logic                                    │
│   → Adjust assertion                                        │
└─────────────────────────────────────────────────────────────┘
```

### Chrome DevTools MCP Verification Pattern

```
┌─────────────────────────────────────────────────────────────┐
│ Step 1: NAVIGATE                                            │
│   Tool: navigate_page                                       │
│   url: "http://localhost:3000/login"                        │
│                                                             │
│ Step 2: SNAPSHOT (inspect DOM)                              │
│   Tool: take_snapshot                                       │
│   → Get full DOM tree                                       │
│   → Find elements and their attributes                      │
│                                                             │
│ Step 3: ACT                                                 │
│   Tool: fill                                                │
│   selector: "[data-testid='email']"                         │
│   value: "test@example.com"                                 │
│                                                             │
│ Step 4: CHECK STATE via JS                                  │
│   Tool: evaluate_script                                     │
│   expression: "document.querySelector('[data-testid=email]').value"│
│   → Verify value was set correctly                          │
│                                                             │
│ Step 5: SCREENSHOT                                          │
│   Tool: take_screenshot                                     │
│   → Visual confirmation                                     │
│                                                             │
│ Step 6: CHECK NETWORK (for form submissions)                │
│   Tool: list_network_requests                               │
│   → Verify API call was made                                │
│   → Check request/response payload                          │
│                                                             │
│ Step 7: GET SPECIFIC REQUEST                                │
│   Tool: get_network_request                                 │
│   → Verify response status, body                            │
└─────────────────────────────────────────────────────────────┘
```

### Selector Discovery via MCP

When you don't know the selectors, use MCP to discover them:

```
1. browser_navigate to the page
2. browser_snapshot to get accessibility tree
3. Read the tree — every interactive element is listed with:
   - Role (button, textbox, link, etc.)
   - Name (visible text or aria-label)
   - data-testid (if present)
4. Map discovered selectors to test actions
5. If no data-testid, use role-based: role="button" name="Submit"
```

### Network Verification via DevTools

For actions that call APIs, verify the network layer:

```
1. list_network_requests after an action
2. Find the relevant API call
3. get_network_request to inspect:
   - Status code (200, 201, etc.)
   - Response body (created item, error message)
   - Request payload (what was sent)
4. Compare with expected behavior in test
```

### Console Error Detection

After each action, check for JS errors:

```
DevTools: list_console_messages → filter for errors
Playwright: browser_console_messages → check for errors
```

If console errors appear after an action, that's a bug — document it.

### Multi-Step Verification Example

Complete login → create → verify → delete flow:

```
── Step 1: Navigate to login ──────────────────────
  browser_navigate url="http://localhost:3000/login"
  browser_snapshot
  CHECK: login form visible? email input? password input? ✅

── Step 2: Fill email ─────────────────────────────
  browser_fill selector="[data-testid='email']" value="test@example.com"
  browser_snapshot
  CHECK: email field has value? ✅

── Step 3: Fill password ──────────────────────────
  browser_fill selector="[data-testid='password']" value="password123"
  browser_snapshot
  CHECK: password field filled? (masked) ✅

── Step 4: Click login ────────────────────────────
  browser_click selector="[data-testid='login-button']"
  browser_snapshot
  CHECK: redirected to /dashboard? user menu visible? ✅

── Step 5: Navigate to tasks ──────────────────────
  browser_click selector="[data-testid='nav-tasks']"
  browser_snapshot
  CHECK: tasks page loaded? task list visible? ✅

── Step 6: Create task ────────────────────────────
  browser_click selector="[data-testid='create-task']"
  browser_snapshot
  CHECK: create form/modal appeared? ✅

  browser_fill selector="[data-testid='task-title']" value="Test Task"
  browser_click selector="[data-testid='save-task']"
  browser_snapshot
  CHECK: task appears in list? success feedback? ✅

── Step 7: Verify persistence ─────────────────────
  browser_navigate url="http://localhost:3000/tasks"
  browser_snapshot
  CHECK: "Test Task" still in list after reload? ✅

── Step 8: Delete task ────────────────────────────
  browser_click selector="text=Test Task"
  browser_click selector="[data-testid='delete-task']"
  browser_click selector="[data-testid='confirm-delete']"
  browser_snapshot
  CHECK: task removed from list? ✅

── RESULT ─────────────────────────────────────────
  8/8 steps verified ✅
  0 selector corrections needed
  0 console errors detected
  Test file: e2e/flows/task-crud.spec.ts confirmed working
```

---

## 11. Running E2E Tests (CLI)

### Playwright Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific flow
npx playwright test e2e/flows/checkout.spec.ts

# Run with UI (headed)
npx playwright test --headed

# Run specific browser
npx playwright test --project=chromium

# Run smoke tests only
npx playwright test e2e/smoke/

# Show HTML report
npx playwright show-report

# Debug mode (step through)
npx playwright test --debug
```

### Cypress Commands

```bash
# Run all (headless)
npx cypress run

# Run specific spec
npx cypress run --spec "cypress/e2e/checkout.cy.ts"

# Open interactive runner
npx cypress open

# Run in specific browser
npx cypress run --browser chrome
```
