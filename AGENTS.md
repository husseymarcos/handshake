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

## Ruby Object-Oriented Design Rules (Sandi Metz POODR Style)

When generating or refactoring Ruby/Rails code, strictly adhere to the following Object-Oriented principles based on Sandi Metz's "Practical Object-Oriented Design in Ruby":

1. **Polymorphism Over Conditionals:**
   - NEVER use complex `if/elsif`, `case/when`, or `unless` statements to check an object's type or state to determine behavior.
   - Refactor conditionals into the Strategy Pattern or use Duck Typing. Inject the varying behavior as interchangeable objects that respond to the same message.

2. **Single Responsibility Principle (SRP):**
   - Classes should have exactly ONE reason to change. If you can't describe what a class does in one sentence without using "and" or "or", it is too big.
   - Extract extra responsibilities into their own small, focused Plain Old Ruby Objects (POROs).

3. **Dependency Injection:**
   - Do not hardcode class instantiation (e.g., `SomeClass.new`) deep inside methods.
   - Pass dependencies (objects or classes) as arguments to the constructor (`initialize`) or the method itself. Rely on abstractions, not concretions.

4. **Tell, Don't Ask:**
   - Do not query an object for its state, make a decision, and then tell it what to do.
   - Instead, send a message to the object and trust it to handle its own behavior and state changes.

5. **Embrace Duck Typing:**
   - Do not check the class of an object (e.g., `is_a?`, `kind_of?`).
   - Care only about what messages an object responds to (its interface), not what it is.

6. **Small Methods:**
   - Keep methods under 5 lines of code. If it requires more, extract the logic into well-named private helper methods.

7. **Isolate External Dependencies:**
   - Wrap external libraries, APIs, or complex framework methods in a facade or adapter class. The core domain logic should not know about the implementation details of the outside world.

## Testing Philosophy (Sandi Metz Style)

**Test messages, not methods.** Tests should verify what objects **do**, not how they do it.

### DO:
- Test the **public interface** — the messages objects respond to
- Test **behavior and output**, not implementation
- Test that collaborating objects receive the expected messages
- Use tests to drive design by revealing coupling and responsibilities

### DO NOT:
- Test private methods
- Test method internals or implementation details
- Use mocks to verify that specific internal methods were called
- Write tests that break when refactoring (test smell: fragile tests)
- Test getters/setters or attribute accessors directly

### Example:
```ruby
# GOOD: Tests the public interface/behavior
blueprint = Blueprint.for(professional)
assert_respond_to blueprint, :content
assert blueprint.content.include?("#set")

# BAD: Tests implementation details
assert_kind_of Blueprints::Default, blueprint
assert_equal "/path/to/file.typst", blueprint.path
```

Tests should act as documentation of the **what**, not the **how**.

## Test Naming

**Test names should read like plain English.** A non-programmer should understand what behavior is being verified without knowing any code terms.

### DO:
- Use **domain language** (words from the business domain, not code concepts)
- Describe **the behavior** in natural language
- Make test names that could be said out loud to a stakeholder

### DO NOT:
- Use class names, method names, or technical terms in test names
- Use underscores as word separators (use spaces after `test` keyword)
- Reference implementation details

### Example:
```ruby
# GOOD: Describes the behavior in domain terms
test "blueprint provides typst content for resume generation" do

# GOOD: Describes what happens, not how
test "adapting a resume uses the professional's capabilities" do

# BAD: References code structure and methods
test "for returns blueprint with typst content" do
test "content delegates to source" do
test "adapt method calls generate_typst" do
```

**The test name is the most important documentation.** If you can't describe the behavior clearly in English, the code design is probably wrong.
