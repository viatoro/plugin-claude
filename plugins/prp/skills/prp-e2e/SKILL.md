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

## 4. Playwright Power Features

### 4.1 Multi-Step Flows with Shared State

Playwright's `test.step()` groups actions into named steps — each step retries independently and shows in the trace viewer:

```typescript
test('complete onboarding flow', async ({ page }) => {
  await test.step('register account', async () => {
    await page.goto('/register');
    await page.fill('[data-testid="email"]', 'new@test.com');
    await page.fill('[data-testid="password"]', 'SecureP@ss1');
    await page.click('[data-testid="register-button"]');
    await expect(page).toHaveURL('/onboarding');
  });

  await test.step('complete profile', async () => {
    await page.fill('[data-testid="display-name"]', 'Test User');
    await page.setInputFiles('[data-testid="avatar-upload"]', 'e2e/fixtures/avatar.png');
    await page.click('[data-testid="next-step"]');
    await expect(page.locator('[data-testid="step-2"]')).toBeVisible();
  });

  await test.step('select preferences', async () => {
    await page.click('[data-testid="pref-dark-mode"]');
    await page.click('[data-testid="pref-notifications"]');
    await page.click('[data-testid="finish-onboarding"]');
    await expect(page).toHaveURL('/dashboard');
  });

  await test.step('verify onboarding complete', async () => {
    // Check profile was saved
    await page.click('[data-testid="user-menu"]');
    await expect(page.locator('[data-testid="display-name"]')).toHaveText('Test User');
    // Check preferences applied
    await expect(page.locator('html')).toHaveClass(/dark/);
  });
});
```

**Why `test.step()`**: When step 3 fails, the trace shows exactly which step — not just "test failed at line 47."

### 4.2 Built-in Retry and Auto-Waiting

Playwright auto-waits for elements and retries assertions. Use this instead of manual waits:

```typescript
// ✅ Auto-retries until element appears (default 5s timeout)
await expect(page.locator('[data-testid="toast-success"]')).toBeVisible();

// ✅ Auto-retries until text matches
await expect(page.locator('[data-testid="count"]')).toHaveText('42');

// ✅ Auto-retries until URL changes
await expect(page).toHaveURL('/dashboard');

// ✅ Wait for specific network response before asserting
const responsePromise = page.waitForResponse(r =>
  r.url().includes('/api/tasks') && r.status() === 200
);
await page.click('[data-testid="save-task"]');
const response = await responsePromise;
const data = await response.json();
expect(data.id).toBeDefined();

// ✅ Custom retry with polling
await expect(async () => {
  const count = await page.locator('[data-testid="item"]').count();
  expect(count).toBeGreaterThan(0);
}).toPass({ timeout: 10_000 });
```

**Configure retries per project** in `playwright.config.ts`:

```typescript
export default defineConfig({
  retries: process.env.CI ? 2 : 0,  // Retry twice in CI, never locally
  use: {
    actionTimeout: 10_000,           // Click, fill, etc.
    navigationTimeout: 30_000,       // goto, waitForURL
  },
  expect: {
    timeout: 5_000,                  // Assertion auto-retry
  },
});
```

### 4.3 Parallel Execution

Playwright runs test files in parallel by default. Control it:

```typescript
// playwright.config.ts
export default defineConfig({
  workers: process.env.CI ? 4 : undefined,  // 4 in CI, auto locally
  fullyParallel: true,                       // Tests within a file also parallel
});
```

**Isolate tests for parallelism** — each test must own its data:

```typescript
// ✅ Each test creates unique data — safe to run in parallel
test('user A creates task', async ({ page, request }) => {
  const { id } = await request.post('/api/test/seed', {
    data: { user: 'user-a@test.com', tasks: [{ title: 'Task A' }] }
  }).then(r => r.json());

  // test using id...

  await request.delete(`/api/test/cleanup/${id}`);
});

test('user B creates task', async ({ page, request }) => {
  const { id } = await request.post('/api/test/seed', {
    data: { user: 'user-b@test.com', tasks: [{ title: 'Task B' }] }
  }).then(r => r.json());

  // test using id...

  await request.delete(`/api/test/cleanup/${id}`);
});
```

**Shard across CI machines**:

```bash
# Machine 1
npx playwright test --shard=1/3

# Machine 2
npx playwright test --shard=2/3

# Machine 3
npx playwright test --shard=3/3
```

### 4.4 Tracing — Debug Failures Like a Time Machine

Traces capture every action, screenshot, network request, and console log:

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    trace: 'on-first-retry',   // Only trace when retrying (saves resources)
    // trace: 'on',            // Always trace (dev mode)
    // trace: 'retain-on-failure', // Keep trace only for failed tests
  },
});
```

**View traces**:

```bash
# After test failure, open the trace viewer
npx playwright show-trace test-results/auth-flow/trace.zip
```

**Force trace for a specific test** (debugging):

```typescript
test('debug this flow', async ({ page, context }) => {
  await context.tracing.start({ screenshots: true, snapshots: true });

  // ... test actions ...

  await context.tracing.stop({ path: 'debug-trace.zip' });
});
```

### 4.5 Auth State — Login Once, Reuse Everywhere

Don't login in every test. Save auth state and reuse:

```typescript
// e2e/support/auth.setup.ts — runs once before all tests
import { test as setup, expect } from '@playwright/test';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@example.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');
  await expect(page).toHaveURL('/dashboard');

  // Save signed-in state to file
  await page.context().storageState({ path: 'e2e/.auth/user.json' });
});
```

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'tests',
      dependencies: ['setup'],
      use: {
        storageState: 'e2e/.auth/user.json',  // All tests start logged in
      },
    },
  ],
});
```

```typescript
// Now every test starts authenticated — no login step needed
test('create task', async ({ page }) => {
  await page.goto('/tasks');  // Already logged in!
  await page.click('[data-testid="create-task"]');
  // ...
});
```

### 4.6 API Mocking — Control External Dependencies

Mock API responses for edge cases you can't reproduce naturally:

```typescript
test('handles payment failure gracefully', async ({ page }) => {
  // ─── Mock the payment API to return failure ───
  await page.route('**/api/payments/charge', route =>
    route.fulfill({
      status: 402,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'card_declined', message: 'Insufficient funds' }),
    })
  );

  // ─── Action: attempt checkout ───
  await page.goto('/checkout');
  await page.fill('[data-testid="card-number"]', '4000000000000002');
  await page.click('[data-testid="pay-button"]');

  // ─── Assert: error shown, not stuck ───
  await expect(page.locator('[data-testid="payment-error"]')).toHaveText(/Insufficient funds/);
  await expect(page.locator('[data-testid="retry-button"]')).toBeVisible();
});

test('handles slow network', async ({ page }) => {
  // Simulate slow API (3 second delay)
  await page.route('**/api/tasks', route =>
    new Promise(resolve => setTimeout(resolve, 3000))
      .then(() => route.continue())
  );

  await page.goto('/tasks');

  // Assert: loading state appears
  await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();

  // Assert: data eventually loads
  await expect(page.locator('[data-testid="task-list"]')).toBeVisible({ timeout: 10_000 });
});
```

### 4.7 Cookies and Session Handling

```typescript
// Read cookies after login
test('session cookie is set', async ({ page, context }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@test.com');
  await page.click('[data-testid="login-button"]');

  const cookies = await context.cookies();
  const session = cookies.find(c => c.name === 'session');
  expect(session).toBeDefined();
  expect(session!.httpOnly).toBe(true);
  expect(session!.secure).toBe(true);
});

// Set cookies before test (skip login entirely)
test('with pre-set session', async ({ context, page }) => {
  await context.addCookies([{
    name: 'session',
    value: 'valid-test-token',
    domain: 'localhost',
    path: '/',
  }]);

  await page.goto('/dashboard');  // Lands directly, no redirect
  await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
});
```

---

## 5. Test Organization (Page Object Model)

### File Structure

```
e2e/
├── tests/                    # Test specs — the user journeys
│   ├── auth.spec.ts
│   ├── checkout.spec.ts
│   ├── task-management.spec.ts
│   └── smoke.spec.ts
├── pages/                    # Page Objects — encapsulate selectors + page actions
│   ├── login.page.ts
│   ├── dashboard.page.ts
│   ├── product.page.ts
│   └── checkout.page.ts
├── actions/                  # Reusable multi-step actions (business flows)
│   ├── user.actions.ts       # login, register, logout
│   ├── cart.actions.ts       # addToCart, applyCoupon, clearCart
│   └── admin.actions.ts      # createProduct, deleteProduct
├── fixtures/                 # Test fixtures — state setup (login, seed data)
│   ├── test.fixture.ts       # Extended test with auth + custom fixtures
│   ├── users.json
│   └── products.json
└── playwright.config.ts
```

### Page Object Pattern

Pages encapsulate selectors and single-page interactions:

```typescript
// e2e/pages/login.page.ts
import { type Page, type Locator } from '@playwright/test';

export class LoginPage {
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly loginButton: Locator;
  readonly errorMessage: Locator;

  constructor(private page: Page) {
    this.emailInput = page.locator('[data-testid="email"]');
    this.passwordInput = page.locator('[data-testid="password"]');
    this.loginButton = page.locator('[data-testid="login-button"]');
    this.errorMessage = page.locator('[data-testid="login-error"]');
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }
}
```

```typescript
// e2e/pages/checkout.page.ts
import { type Page, type Locator } from '@playwright/test';

export class CheckoutPage {
  readonly shippingName: Locator;
  readonly shippingAddress: Locator;
  readonly cardNumber: Locator;
  readonly placeOrderButton: Locator;
  readonly orderConfirmation: Locator;

  constructor(private page: Page) {
    this.shippingName = page.locator('[data-testid="shipping-name"]');
    this.shippingAddress = page.locator('[data-testid="shipping-address"]');
    this.cardNumber = page.locator('[data-testid="card-number"]');
    this.placeOrderButton = page.locator('[data-testid="place-order"]');
    this.orderConfirmation = page.locator('[data-testid="order-confirmation"]');
  }

  async fillShipping(name: string, address: string) {
    await this.shippingName.fill(name);
    await this.shippingAddress.fill(address);
  }

  async fillPayment(card: string) {
    await this.cardNumber.fill(card);
  }

  async placeOrder() {
    await this.placeOrderButton.click();
  }
}
```

### Actions Pattern

Actions combine multiple page interactions into reusable business flows:

```typescript
// e2e/actions/user.actions.ts
import { type Page } from '@playwright/test';
import { LoginPage } from '../pages/login.page';

export class UserActions {
  private loginPage: LoginPage;

  constructor(private page: Page) {
    this.loginPage = new LoginPage(page);
  }

  async login(email = 'test@example.com', password = 'password123') {
    await this.loginPage.goto();
    await this.loginPage.login(email, password);
    await this.page.waitForURL('/dashboard');
  }

  async logout() {
    await this.page.click('[data-testid="user-menu"]');
    await this.page.click('[data-testid="logout"]');
    await this.page.waitForURL('/login');
  }
}
```

```typescript
// e2e/actions/cart.actions.ts
import { type Page } from '@playwright/test';
import { ProductPage } from '../pages/product.page';

export class CartActions {
  constructor(private page: Page) {}

  async addToCart(productName: string) {
    const card = this.page.locator('[data-testid="product-card"]', { hasText: productName });
    await card.locator('[data-testid="add-to-cart"]').click();
  }

  async applyCoupon(code: string) {
    await this.page.fill('[data-testid="coupon-input"]', code);
    await this.page.click('[data-testid="apply-coupon"]');
  }
}
```

### Fixtures Pattern

Fixtures provide test state — auth, seed data, page objects:

```typescript
// e2e/fixtures/test.fixture.ts
import { test as base } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { CheckoutPage } from '../pages/checkout.page';
import { UserActions } from '../actions/user.actions';
import { CartActions } from '../actions/cart.actions';

type TestFixtures = {
  loginPage: LoginPage;
  checkoutPage: CheckoutPage;
  userActions: UserActions;
  cartActions: CartActions;
};

export const test = base.extend<TestFixtures>({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  checkoutPage: async ({ page }, use) => {
    await use(new CheckoutPage(page));
  },
  userActions: async ({ page }, use) => {
    await use(new UserActions(page));
  },
  cartActions: async ({ page }, use) => {
    await use(new CartActions(page));
  },
});

export { expect } from '@playwright/test';
```

### Test Spec — Clean and Short

Tests import from fixtures. All logic lives in pages/actions:

```typescript
// e2e/tests/checkout.spec.ts
import { test, expect } from '../fixtures/test.fixture';

test.describe('Checkout Flow', () => {
  test.beforeEach(async ({ userActions }) => {
    await userActions.login();
  });

  test('browse, add to cart, and complete checkout', async ({
    page, cartActions, checkoutPage
  }) => {
    // ─── Action 1: Browse products ───
    await page.goto('/products');
    await expect(page.locator('[data-testid="product-card"]')).toHaveCount(6);

    // ─── Action 2: Add to cart ───
    await cartActions.addToCart('Wireless Headphones');
    await expect(page.locator('[data-testid="cart-badge"]')).toHaveText('1');

    // ─── Action 3: Apply coupon ───
    await page.goto('/cart');
    await cartActions.applyCoupon('SAVE10');
    await expect(page.locator('[data-testid="discount"]')).toBeVisible();

    // ─── Action 4: Checkout ───
    await page.click('[data-testid="checkout-button"]');
    await checkoutPage.fillShipping('John Doe', '123 Main St');
    await checkoutPage.fillPayment('4242424242424242');
    await checkoutPage.placeOrder();

    // ─── Assert: order confirmed ───
    await expect(checkoutPage.orderConfirmation).toBeVisible();
  });
});
```

### Why This Structure

| Layer | Responsibility | Changes when... |
|-------|---------------|-----------------|
| `tests/` | User journeys | Business flow changes |
| `pages/` | Selectors + single-page actions | UI changes (new selectors) |
| `actions/` | Multi-page business flows | Feature logic changes |
| `fixtures/` | Test state setup | Auth or data setup changes |

**Key rule**: Tests never contain selectors. Pages never contain assertions. Actions combine pages. Fixtures provide state.

### Naming Convention

```
{feature}.spec.ts         # Test spec
{page-name}.page.ts       # Page object
{domain}.actions.ts        # Business actions
test.fixture.ts            # Shared fixtures
smoke.spec.ts              # Critical path only
```

---

## 6. Best Practices

### Rule 1: Keep Tests Short — Move Logic to Actions

```typescript
// ❌ BAD: test contains selectors and implementation details
test('checkout', async ({ page }) => {
  await page.locator('[data-testid="email"]').fill('test@test.com');
  await page.locator('[data-testid="password"]').fill('pass');
  await page.locator('[data-testid="login-btn"]').click();
  await page.waitForURL('/dashboard');
  await page.goto('/products');
  await page.locator('[data-testid="product-card"]').first()
    .locator('[data-testid="add-to-cart"]').click();
  // ... 30 more lines of selectors
});

// ✅ GOOD: test reads like a story, logic lives in actions/pages
test('checkout', async ({ userActions, cartActions, checkoutPage }) => {
  await userActions.login();
  await cartActions.addToCart('Headphones');
  await checkoutPage.fillShipping('John Doe', '123 Main St');
  await checkoutPage.fillPayment('4242424242424242');
  await checkoutPage.placeOrder();
  await expect(checkoutPage.orderConfirmation).toBeVisible();
});
```

### Rule 2: Use `data-testid` — Never CSS Selectors

```typescript
// ❌ Fragile — breaks on CSS refactor
await page.click('.btn.btn-primary.submit-form');
await page.click('#checkout-submit');

// ✅ Stable — only changes when feature changes
await page.click('[data-testid="submit-order"]');
```

| Priority | Selector | When |
|----------|----------|------|
| 1st | `[data-testid="..."]` | Always preferred |
| 2nd | `role="button"` + `name="..."` | When data-testid not available |
| 3rd | `text="Submit"` | Last resort for simple labels |
| Never | `.class`, `#id`, `nth-child` | Too fragile |

### Rule 3: No Hard Waits — Use Locator Assertions

```typescript
// ❌ Arbitrary wait — flaky, slow
await page.waitForTimeout(3000);
await page.click('[data-testid="item"]');

// ✅ Wait for specific state
await expect(page.locator('[data-testid="item"]')).toBeVisible();
await page.click('[data-testid="item"]');

// ✅ Wait for network response
const response = page.waitForResponse(r => r.url().includes('/api/save'));
await page.click('[data-testid="save"]');
await response;

// ✅ Wait for URL change
await page.click('[data-testid="submit"]');
await expect(page).toHaveURL('/success');

// ✅ Retry assertion with polling
await expect(async () => {
  const count = await page.locator('[data-testid="item"]').count();
  expect(count).toBe(5);
}).toPass({ timeout: 10_000 });
```

### Rule 4: Use Fixtures for State

```typescript
// ❌ Login in every test via UI — slow, repetitive
test.beforeEach(async ({ page }) => {
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@test.com');
  await page.fill('[data-testid="password"]', 'password123');
  await page.click('[data-testid="login-button"]');
});

// ✅ Use fixture — login state injected, no UI needed
// In test.fixture.ts:
export const test = base.extend({
  authenticatedPage: async ({ browser }, use) => {
    const context = await browser.newContext({
      storageState: 'e2e/.auth/user.json',
    });
    const page = await context.newPage();
    await use(page);
    await context.close();
  },
});

// In test:
test('dashboard loads', async ({ authenticatedPage: page }) => {
  await page.goto('/dashboard');  // Already logged in
});
```

### Rule 5: Parallelize Safely — No Shared State

```typescript
// ❌ Tests share data — breaks in parallel
let taskId: string;
test('create task', async ({ page }) => {
  // creates task, saves to taskId
});
test('delete task', async ({ page }) => {
  // uses taskId from previous test — FAILS in parallel
});

// ✅ Each test owns its data
test('create and delete task', async ({ page, request }) => {
  // Seed unique data
  const { id } = await request.post('/api/test/seed', {
    data: { title: `task-${Date.now()}` }
  }).then(r => r.json());

  // Test with it
  await page.goto(`/tasks/${id}`);
  await page.click('[data-testid="delete"]');

  // Cleanup
  await request.delete(`/api/test/cleanup/${id}`);
});
```

### Summary Table

| Practice | Rule | Why |
|----------|------|-----|
| Short tests | Move logic to `actions/` and `pages/` | Readable, maintainable |
| `data-testid` | Never use CSS selectors | Survives redesigns |
| No hard waits | Use `toBeVisible()`, `waitForResponse()` | No flakiness |
| Fixtures | Use for auth, seed data, page objects | Fast, reusable state |
| No shared state | Each test creates/cleans its own data | Safe parallelism |

---

## 7. API + UI Hybrid Tests

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

## 8. Multi-Tab / Multi-User Tests (Playwright)

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

## 9. Mobile / Responsive Tests (Playwright)

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

## 10. Smoke Test Template

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

## 11. Interactive MCP Verification

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

## 12. Running E2E Tests (CLI)

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
