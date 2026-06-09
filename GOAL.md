# ask-linear — Ulinear Service Context

## Purpose

Service context gem for Ulinear. Provides three files:
- `context.rb` — metadata for the system prompt (API docs, auth instructions, quick-start code snippets)
- `client.rb` — authenticated API client helper
- `error_guide.rb` — structured error knowledge for agents

No tool classes. The agent reads the context from the system prompt, writes Ruby code using the `client` helper, and executes it with the `Code` tool from `ask-tools-shell`.

## Dependencies

- **Runtime:**
  - `ask-auth` (for `Ask::Auth.resolve(:service_token)`)
  - `Ulinear` API client gem (e.g., `slack-ruby-client`, `notion-ruby`, `linear-ruby`)
- **Build/test:** minitest, mocha, rake, vcr, webmock
- **This gem MUST wait until `ask-auth` is built, tested, and released.** The client helper depends on `Ask::Auth.resolve`.

## Implementation Steps

### 1. Define the gem scaffold
- `lib/ask-linear.rb` — entry point
- `lib/ask/linear.rb` — module
- `lib/ask/linear/version.rb`
- `lib/ask/linear/context.rb` — metadata constants
- `lib/ask/linear/client.rb` — authenticated client helper
- `lib/ask/linear/error_guide.rb` — structured error knowledge
- `ask-linear.gemspec` — depends on `ask-auth`, the service's official Ruby client

### 2. Research the service's API
- Find the official API docs URL
- Find if there's an OpenAPI spec
- Identify the auth mechanism (API key, OAuth, personal token)
- Identify the official Ruby client gem
- Determine common operations agents would need
- Map common error responses and their meanings

### 3. Build context.rb
Define constants following the `ask-github` pattern: `DESCRIPTION`, `DOCS_URL`, `OPENAPI_URL` (if available), `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_DOCS`, `QUICK_START`.

### 4. Build client.rb
- `Ask::Ulinear.client` returns an authenticated client
- Resolves token via `Ask::Auth.resolve(:service_token)`
- Raises `Ask::Auth::MissingCredential` with instructions if no token found
- Configures sensible defaults (pagination, timeout, user agent)

### 5. Build error_guide.rb
- Map of common error patterns
- Rate limit info
- Pagination info
- Common HTTP status codes and their meanings

### 6. Test coverage
- Test context constants are accessible and correct
- Test client returns authenticated client
- Test client raises appropriate errors when credentials missing or invalid
- Test error guide maps are accurate

### 7. README
- Quick start: `Ask::Ulinear.client` and writing agent code
- Auth setup instructions
- Common usage patterns
- How to develop and test locally

## What "Done" Means

- `Ask::Ulinear.client` returns authenticated API client
- Context constants provide all metadata an agent needs
- Error guide provides actionable recovery info
- Tests pass with mocked credentials and API responses
- Following the `ask-github` template exactly (it's the reference implementation)
- README documents auth setup and common patterns

## Documentation

### Documentation
- **Update ask-docs** after releasing v0.1.0 — the docs site at github.com/ask-rb/ask-docs must reflect this gems API, usage, and position in the ecosystem.
- The ask-docs repo has a Jekyll site with sections for each gem under core/, providers/, tools/, agent/.
- Add or update the relevant page(s) and submit a PR to ask-docs.
- This is not optional — ask-docs is the public face of the ecosystem.

## Improving Parent Gems During Development

### Improving Parent Gems During Development

If during development you discover something in a parent gem (a dependency of this gem)
that needs to be fixed or improved:

1. Make the change in the parent gem's repository at `/Users/kaka/Code/ask-rb/GEMNAME/`
2. Ensure existing tests in the parent gem still pass: `cd ../PARENT && bundle exec rake test`
3. Ensure tests in THIS gem still pass: `bundle exec rake test`
4. Ensure the parent gem still builds: `gem build *.gemspec`
5. Commit the parent gem change, bump its patch version, and push:
   `cd ../PARENT && git commit -m "fix: ..." && git push`
6. Update this gem's Gemfile to reference the updated parent gem
7. Continue with this gem's implementation using the fixed parent

Do NOT break parent functionality. Do NOT change parent APIs without testing
both gems. Parent gems have their own consumers — treat them with care.

## Release Checklist (Required for v0.1.0)

Before declaring this gem done and releasing v0.1.0, verify:

- [] All tests pass with >90% coverage
- [] Every public API method has documentation (yardoc or inline comments)
- [] README is complete: installation, quick start, configuration, development
- [] CHANGELOG.md exists with an entry for v0.1.0
- [] All code is committed and pushed to github.com/ask-rb/ask-linear
- [] Gem builds without errors: gem build *.gemspec
- [] Gem is released as a private gem (see guides/RELEASING.md when available)
- [] A consumer app can install, require, and use the gem with no errors
- [] Thread-safety verified (registry, config, client construction)
- [] Error messages are helpful and actionable

## What Done Means for v0.1.0

The gem reaches v0.1.0 when:
- All implementation steps above are complete and tested
- The gem is released on GitHub Packages as a private gem
- A real consumer can install it with gem install or Bundler
- A consumer script can require it and use its full public API
- The README provides enough information for someone unfamiliar to get started in 5 minutes
- The CHANGELOG documents what v0.1.0 delivers

## Development Workflow

### Git conventions
- Follow the git-workflow skill for branch naming, commit messages, and PR structure.
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- One logical change per commit. No "fixup" or "wip" commits on main.
- Commit messages must be one direct sentence describing the change.

### Reference projects
Study existing implementations for patterns and conventions:

- **ask-tools-shell** — extract from `ruby_llm-conductor/lib/ruby_llm/conductor/tools/`
- **ask-agent** — port from `ruby_llm-conductor/` (session, loop, tool_executor, compactor, etc.)
- **ask-rails** — transform from `solid_agents/` (railtie, generators, persistence)
- **ask-openai, ask-anthropic** — study `ruby_llm/lib/ruby_llm/providers/` for wire formats and streaming patterns
- **ask-openai** — also study `llm-proxy/lib/llm_proxy/protocols/` for OpenAI protocol conversion
- **General patterns** — study `pi/packages/ai/src/providers/` for lazy loading, registration, and protocol families
- **Test patterns** — study `ruby_llm/spec/` for VCR cassette structure and integration testing patterns
- **ask-github** — reference implementation for service context gems; follow its three-file pattern
### Reference Repositories (Local)
All ask-rb gem repos are available locally at /Users/kaka/Code/ask-rb/ for reference.
Do not clone from GitHub — use the local directories:
- Source code: /Users/kaka/Code/ask-rb/GEMNAME/lib/
- Tests: /Users/kaka/Code/ask-rb/GEMNAME/test/
- Goal: /Users/kaka/Code/ask-rb/GEMNAME/GOAL.md
- Gemspec: /Users/kaka/Code/ask-rb/GEMNAME/GEMNAME.gemspec

Other reference projects in the same workspace:
- /Users/kaka/Code/ask-rb/ruby_llm/ — RubyLLM gem (providers, models, streaming)
- /Users/kaka/Code/ask-rb/ruby_llm-conductor/ — Original conductor (agent loop, tools)
- /Users/kaka/Code/ask-rb/llm-proxy/ — Protocol normalization patterns
- /Users/kaka/Code/ask-rb/pi/ — Pi agent (TypeScript, provider architecture)
- /Users/kaka/Code/ask-rb/solid_agents/ — Original solid_agents (Rails engine)
- /Users/kaka/Code/ask-rb/composio/ — Composio SDK (MCP tool execution examples)
- /Users/kaka/Code/ask-rb/ask-docs/ — Documentation site (update after release)

### Testing
- Use Minitest (not RSpec) — consistent with the ask-rb ecosystem.
- Unit tests for every public method (normal path + edge cases + error cases).
- Integration tests with VCR cassettes for any gem that calls external APIs.
- Run the full suite before every commit: `bundle exec rake test`.
