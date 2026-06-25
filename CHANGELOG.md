## [0.1.2] - 2026-06-25

### Changed
- Gemspec validation test. Infrastructure: rubocop, overcommit, bin/setup, CI matrix.
# Changelog

## [0.1.1] - 2026-06-21

### Added

- Initial release of `ask-linear` — Linear service context for the ask-rb ecosystem.
- **context.rb** — Metadata constants for AI system prompts: `DESCRIPTION`, `DOCS_URL`, `GRAPHQL_URL`, `AUTH_NAME`, `AUTH_HOW`, `GEM_NAME`, `GEM_DOCS`, `QUICK_START`
- **client.rb** — `Ask::Linear.client` returns an authenticated GraphQL client via `Ask::Auth.resolve(:linear_api_key)`. Uses Faraday to send GraphQL queries to the Linear API at `https://api.linear.app/graphql`. Wraps client in `ClientProxy` to convert `Faraday::UnauthorizedError` (HTTP 401) to `Ask::Auth::InvalidCredential`.
- **error_guide.rb** — `Ask::Linear::Errors` with rate limit info, HTTP status code descriptions, and GraphQL error extension guidance for agents.
- **Dependencies:** `ask-auth ~> 0.1`, `faraday ~> 2.0`
- **Testing:** 26 tests, 62 assertions covering context constants, client auth flow, and error guide lookups.
