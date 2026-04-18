# Handshake Implementation Plan

## Core Requirements

### PDF Validation

- All generated CVs must be exactly one page
- Validate page count post-compilation using `pdfinfo`
- If > 1 page: retry up to **3 attempts** with progressively stricter constraints
- After 3 failures: return error to user with "Unable to fit content to one page" message

### LLM Caching

- Cache generated Typst code keyed by hash of (user_id + company_name + job_description)
- TTL: 24 hours to allow for profile updates
- Skip cache if blueprint template has been modified since cache entry

### Content Limits

- Job description: maximum 8000 tokens (~6000 words) to manage costs and quality
- Truncate with warning if exceeded

---

## Architecture Overview

**Framework:** Ruby on Rails 7.2+ with Hotwire (Turbo + Stimulus)

**Database:** SQLite with multi-database support for Solid Queue/Solid Cache

**AI Integration:** RubyLLM gem configured to use Google Gemini 2.5 Flash Preview

**PDF Pipeline:** Typst CLI compilation with page validation

**Authentication:** Custom session-based (~150 lines, no Devise)

**Styling:** Native CSS with `@layer` architecture (no Tailwind)

**Background Jobs:** Solid Queue (database-backed, no Redis)

---

## Data Model

### User

- Email, password digest
- Blueprint template (Typst source text column)
- Has many Skills
- Has many Projects
- Has many Applications (history)
- Has many Sessions
- Timestamp for cache invalidation (blueprint_updated_at)

### Skill

- Name, belongs to User

### Project

- Name, year, title, description, stack, GitHub URL
- Belongs to User

### Application (Resume History)

- Company name, job description
- Generated Typst source
- Attached PDF (Active Storage)
- Created timestamp

### LLM Cache (Solid Cache)

- Key: hash of user_id + company + job_description
- Value: generated Typst code
- TTL: 24 hours

---

## Domain Logic

### Resume Generation Flow

1. User provides company name + job description (max 8000 tokens)
2. Check cache: if fresh entry exists, use cached Typst code
3. If cache miss: build prompt combining user's blueprint + user's skills + user's projects + job requirements
4. RubyLLM (configured for Google Gemini) generates optimized Typst code
5. Typst CLI compiles to PDF
6. `pdfinfo` validates: must be exactly 1 page
7. If validation fails (pages > 1):
  - Attempt 1: retry with tighter spacing hints in prompt
  - Attempt 2: retry with smaller font hints
  - Attempt 3: retry with aggressive content condensation
  - Attempt 4+: return error "Unable to fit content to one page. Try removing skills or shortening job description."
8. Store validated PDF + Typst source
9. Cache Typst result for 24 hours
10. User downloads or views history

### Career Profile Management (The Library)

- Add/remove skills
- Add/remove projects with full metadata
- Edit blueprint template (raw Typst column on User) - updates invalidate LLM cache

### Authentication

- Custom Sessions controller with secure tokens
- Cookie-based session storage
- Password authentication with bcrypt

---

## Controller Structure

Map all actions to REST resources:


| Resource     | Purpose                                                    |
| ------------ | ---------------------------------------------------------- |
| Sessions     | Sign in/out                                                |
| Users        | Edit blueprint template (The Library main view)            |
| Skills       | Add/remove skills                                          |
| Projects     | List/add/remove projects                                   |
| Applications | Create (generate), list history, show result, download PDF |


---

## Testing Strategy

**Framework:** Minitest with fixtures (no RSpec, no FactoryBot)

**Scope:** Model tests + Integration tests only (no system tests)

**Style:** TDD-style naming describing behavior, not implementation

**Coverage:**

- Career profile management (adding skills makes them available, removing hides them)
- Resume generation creates valid one-page PDFs
- Cache hits skip LLM calls, cache misses trigger generation
- Blueprint updates invalidate cache
- History shows applications newest-first
- Authentication gates protected resources
- Invalid generation inputs return appropriate errors
- PDF validation retries 3 times before failing

---

## Design System

### Visual Language

- Background: warm off-white (#FDFCF8)
- Text: high-contrast black
- Accent: trustworthy blue (#2563EB)
- Headings: bold sans-serif, tight tracking
- Body text: readable serif for document feel

### UI Patterns

- Massive input fields (no visible borders until focus)
- Pill-shaped navigation buttons
- Generous whitespace
- Rounded-3xl cards with soft shadows
- Hand-drawn aesthetic touches

---

## Key Constraints

### PDF Generation

- Maximum 1 page (enforced via pdfinfo validation)
- **3 retry attempts** with progressive tightening
- Job description limit: 8000 tokens (~6000 words)

### LLM Caching

- 24-hour TTL keyed on content hash
- Cache invalidated when blueprint template changes
- Avoids unnecessary API calls for identical inputs

### Code Philosophy (DHH Style)

- Rich domain models with verb methods (e.g., `user.add_skill`)
- Database-backed everything (no Redis)
- State tracked via associations, not booleans
- Minimal validations on models, use form objects for context
- CRUD controllers, no custom actions
- Jobs as shallow wrappers around model methods

---

## Implementation Sequence

1. **Foundation:** Rails setup, migrations, Current attributes
2. **Authentication:** Custom sessions, sign in/out flow
3. **Career Profile Core:** User with skills and projects CRUD
4. **AI Integration:** RubyLLM config, prompt building, generation logic
5. **Caching:** Solid Cache integration for LLM results
6. **PDF Pipeline:** Typst CLI integration, pdfinfo validation, 3-attempt retry logic
7. **Applications:** Generation flow, cache-aware logic, history, PDF download
8. **UI:** CSS architecture, views, Stimulus controllers
9. **Tests:** Model and integration test coverage with TDD-style naming

---

## Notes

- Single template per user (no multi-template support needed)
- PDF validation is critical - never allow multi-page CVs
- Caching saves API costs and improves response times
- DHH practices: fat models, thin controllers, minimal gems