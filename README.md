# ask-linear

[![Gem Version](https://badge.fury.io/rb/ask-linear.svg)](https://badge.fury.io/rb/ask-linear)

> **⚠️ DEPRECATED:** This gem is deprecated in favor of Linear's official MCP
> server. Existing gem installations may continue to work, but this repository
> will receive no further feature development.

Linear service context for AI agents in the ask-rb ecosystem. It provides an
authenticated GraphQL client for the Linear API, metadata constants for
system prompts, and a structured error guide for common Linear API issues.

## Installation

```ruby
gem "ask-linear"
```

## Quick Start

```ruby
require "ask-linear"

client = Ask::Linear.client

# List all teams
result = client.query("query { teams { nodes { id key name } } }")

# Create an issue
result = client.query(
  "mutation($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id identifier title url } } }",
  { input: { teamId: "TEAM_ID", title: "My issue", description: "Description here" } }
)

# Fetch a specific issue
result = client.query(
  "query($id: String!) { issue(id: $id) { id identifier title description state { name } assignee { name } url } }",
  { id: "ISSUE_ID" }
)
```

## Authentication

`Ask::Linear.client` resolves an API key via
`Ask::Auth.resolve(:linear_api_key)`. Set it in your environment:

```bash
export LINEAR_API_KEY=your_api_key_here
```

Or add it to `~/.ask/credentials.yml`:

```yaml
linear_api_key: your_api_key_here
```

Credentials can also come from Rails credentials, a database, or an OAuth
provider, depending on your `ask-auth` configuration. Generate a personal API
key at [linear.app/settings/api](https://linear.app/settings/api).

## Key entry points

- `Ask::Linear.client` - an authenticated `Ask::Linear::Client` that wraps
  Faraday and sends GraphQL queries to `https://api.linear.app/graphql`.
  Auth failures (HTTP 401) are converted into
  `Ask::Auth::InvalidCredential`.
- `client.query(gql, variables = {})` - execute a GraphQL query or mutation.
  Returns the parsed response body, or raises `RuntimeError` if Linear
  returns GraphQL errors.
- `Ask::Linear::Errors` - structured error knowledge for agents: GraphQL
  extension code lookup, HTTP status descriptions, rate limit and pagination
  guidance.
- `Ask::Linear::DESCRIPTION`, `DOCS_URL`, `GRAPHQL_URL`, `AUTH_NAME`,
  `GEM_NAME`, and `QUICK_START` - metadata constants for system prompts.

## Full documentation

The full ask-rb documentation lives at https://ask-rb.github.io/ask-docs.
[Services: Linear](https://ask-rb.github.io/ask-docs/services/linear) covers
ask-linear in depth, including the client API, error guide, and constants.
API reference: https://ask-rb.github.io/ask-docs/reference/api.

## Development

```
bundle install
bundle exec rake test
```

## License

MIT
