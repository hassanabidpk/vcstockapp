# Code Style Rules (Web + API)

## TypeScript

- TypeScript everywhere — no `any` unless absolutely unavoidable
- Use strict mode (`"strict": true` in tsconfig)
- Prefer `interface` for object shapes, `type` for unions/intersections
- Use path aliases (`@/` for web, configured in tsconfig)

## Express API (`apps/api`)

- Architecture: routes → controllers → services → repositories
- Keep business logic OUT of route handlers
- Version all routes under `/v1/`
- Use Zod for request validation at the boundary
- Consistent error format: `{ error: { code, message, details? } }`
- Always return proper HTTP status codes
- Use `pino` for structured logging — never `console.log` in API code
- Add request ID middleware for tracing

## Next.js Frontend (`apps/web`)

- Use App Router (not Pages Router)
- Prefer server components where appropriate
- Use a single API client wrapper for all backend calls
- Handle auth tokens via cookies (not localStorage)
- Use `cache` and `revalidate` intentionally — never cache user-specific responses
- Tailwind CSS for styling — use `dark:` prefix for dark mode support
- All components support both light and dark themes

## General

- Keep functions small and testable
- No silent failures — log and surface errors
- Follow existing lint rules and formatting (ESLint + Prettier)
- Use `const` by default, `let` only when reassignment is needed
- Prefer early returns over deep nesting
- Destructure props and parameters where it improves readability

## File Organization

- Components: `src/components/{feature}/` or `src/components/ui/`
- Hooks: `src/hooks/`
- Context providers: `src/context/`
- API routes: `src/routes/v1/`
- Services: `src/services/`
- Shared packages: `packages/`
