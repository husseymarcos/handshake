# Handshake — Agent Guide

Ruby on Rails 8.1 application for generating tailored resumes via AI adaptation.

## Quick Start

```bash
bin/setup          # Install deps, setup DB, start server
bin/dev            # Start dev server only (calls bin/rails server)
```

**Required:**

- Ruby 3.4.8
- Typst CLI installed and in PATH (for PDF generation)
- `GEMINI_API_KEY` in `.env` file (Google Gemini via RubyLLM)

## Running Tests

```bash
bin/rails db:test:prepare test           # Unit/integration tests
bin/rails db:test:prepare test:system    # System tests only
bin/rubocop -f github                    # Lint (uses rubocop-rails-omakase)
bin/brakeman --no-pager                  # Security scan
bin/bundler-audit                        # Gem vulnerability scan
```

**Test stack:** Minitest (not RSpec), fixtures (not FactoryBot). Support helpers in `test/support/`.

## Key Architecture

**Database:** SQLite (multi-database for Solid Queue/Cache/Cable — no Redis needed)

**Styling:** Native CSS with `@layer` architecture — **no Tailwind**. Warm off-white background (#FDFCF8).

**Background jobs:** Solid Queue (database-backed)

**AI integration:** RubyLLM gem → Google Gemini 2.5 Flash Preview

**PDF generation:** Typst CLI → compiled to PDF → validated with `pdfinfo` (must be exactly 1 page)

## Domain Language (Critical)

Use these terms in code and tests:

| Code Term | User-Facing Term | Meaning |
|-----------|------------------|---------|
| `Professional` | Professional | Person using the app |
| `Capability` | Capability | Skill/technology (was `Skill`) |
| `Experience` | Experience | Professional experience/portfolio item (was `Project`, `Work`) |
| `Opportunity` | Opportunity | Job application (was `JobApplication`) |
| `organization_name` | Organization | Company name |
| `posting` | Posting | Job description |
| `adapt!` | Adapt | AI transformation process |

See `UBIQUITOUS_LANGUAGE.md` for full glossary.

## Critical Constraints

- **PDF must be exactly 1 page** — enforced via `pdfinfo` validation with 3 retry attempts
- Posting limit: 8000 tokens
- LLM cache TTL: 24 hours (keyed on professional_id + organization + posting hash)
- Blueprint updates invalidate LLM cache

## CI Pipeline

Runs on PR/push to main:

1. `bin/brakeman --no-pager`
2. `bin/bundler-audit`
3. `bin/importmap audit`
4. `bin/rubocop -f github`
5. `bin/rails db:test:prepare test`
6. `bin/rails db:test:prepare test:system`

## Code Style

- **Omakase Ruby/Rails style** (rubocop-rails-omakase)
- Fat models, thin controllers (DHH style)
- Minimal gems, database-backed everything
- RESTful controllers — no custom actions
- CRUD only, state via associations not booleans

## File Locations

- Controllers: `app/controllers/`
- Models: `app/models/` (check `concerns/` for shared logic)
- Views: `app/views/`
- CSS: `app/assets/stylesheets/` (native CSS, no Tailwind)
- Tests: `test/` (models/, controllers/, integration/, system/)
- Fixtures: `test/fixtures/`
- Support helpers: `test/support/`
- Routes: `config/routes.rb`

## Environment Variables

Required in `.env`:

```bash
GEMINI_API_KEY=your_key_here
```
