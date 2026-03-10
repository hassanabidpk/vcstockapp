# Testing Rules

## API (`apps/api`)

- Unit tests for services and utility functions
- Integration tests for critical API endpoints (auth, portfolios, holdings)
- Test happy path + key failure modes (validation errors, 401, 404, rate limits)
- Use consistent error format assertions: `{ error: { code, message } }`

## Web (`apps/web`)

- E2E tests (Playwright) for core user flows if present
- Test login, dashboard load, portfolio switching, navigation

## General

- When adding features, include tests for happy path and key failure modes
- Never mock what you can test directly
- Keep tests close to the code they test
