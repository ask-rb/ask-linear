# ask-linear

Linear service context for AI agents in the ask-rb ecosystem.

Provides an authenticated GraphQL client, metadata constants for system prompts, and a structured error guide for common Linear API issues.

```ruby
gem "ask-linear"
```

## Quick Start

### Get an authenticated client

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

The client is a thin wrapper over Faraday that sends GraphQL queries to `https://api.linear.app/graphql`. Wrapped in a proxy that converts `Faraday::UnauthorizedError` (HTTP 401) into `Ask::Auth::InvalidCredential` with actionable error messages.

### Authentication

The client resolves a Linear API key via `Ask::Auth.resolve(:linear_api_key)`. API keys can be provided through any configured auth provider:

1. **Environment variable:** `LINEAR_API_KEY`
2. **Credentials file:** `~/.ask/credentials.yml`
3. **Rails credentials:** `Rails.application.credentials.linear_api_key`
4. **OAuth / Database:** Custom providers

Generate an API key at [linear.app/settings/api](https://linear.app/settings/api).

## Context Constants

Use these constants to build system prompts for AI agents:

| Constant | Value |
|---|---|
| `Ask::Linear::DESCRIPTION` | "Linear — issue tracking, project management, roadmaps, sprints" |
| `Ask::Linear::DOCS_URL` | https://developers.linear.app/docs |
| `Ask::Linear::GRAPHQL_URL` | https://api.linear.app/graphql |
| `Ask::Linear::AUTH_NAME` | `:linear_api_key` |
| `Ask::Linear::AUTH_HOW` | "https://linear.app/settings/api — generate a personal API key" |
| `Ask::Linear::GEM_NAME` | `"faraday"` |
| `Ask::Linear::QUICK_START` | Copy-paste Ruby code snippet with common GraphQL operations |

## Error Guide

`Ask::Linear::Errors` provides structured knowledge for agents:

```ruby
# Look up GraphQL error extension codes
Ask::Linear::Errors.for("AUTHENTICATION_ERROR")
# => { message: "...", action: "..." }

# Describe HTTP status codes
Ask::Linear::Errors.status_code_description(401)
# => "Unauthorized — API key is missing, invalid, or revoked."

# Rate limit info
Ask::Linear::Errors::RATE_LIMIT[:authenticated]
# => "100 requests per minute per API key"

# Pagination guidance
Ask::Linear::Errors::PAGINATION[:cursor_based]
# => "Linear uses cursor-based pagination with first/after or last/before arguments."
```

### Supported Error Codes

| Extension Code | When It Occurs |
|---|---|
| `AUTHENTICATION_ERROR` | Missing, invalid, or revoked API key |
| `FORBIDDEN` | API key lacks permission for the resource |
| `NOT_FOUND` | Resource doesn't exist or is inaccessible |
| `RATE_LIMITED` | API rate limit exceeded (100 req/min/key) |
| `INPUT_VALIDATION_ERROR` | Input data fails validation |
| `DUPLICATE_INPUT` | Resource with same data already exists |
| `INTERNAL_ERROR` | Linear server error |
| `USER_SUSPENDED` | Authenticated user account is suspended |
| `WORKSPACE_SUSPENDED` | Workspace is suspended or deactivated |

## Client API

### `Ask::Linear.client`

Returns an authenticated `Ask::Linear::Client` wrapped in a `ClientProxy` that catches 401 errors.

### `client.query(gql, variables = {})`

Executes a GraphQL query or mutation against the Linear API.

**Arguments:**
- `gql` (String) — The GraphQL query or mutation string
- `variables` (Hash) — Variables to interpolate into the query (optional)

**Returns:** Hash with `"data"` key containing the response

**Raises:**
- `Ask::Auth::MissingCredential` if no API key is configured
- `Ask::Auth::InvalidCredential` if the API key returns 401
- `RuntimeError` if the API returns GraphQL errors

### Example: Common Operations

```ruby
client = Ask::Linear.client

# List teams
teams = client.query("query { teams { nodes { id key name } } }")

# List my assigned issues
my_issues = client.query("query { viewer { assignedIssues { nodes { id identifier title state { name } } } } }")

# Get workflow states for a team
states = client.query("query($teamId: String!) { team(id: $teamId) { states { nodes { id name type } } } }",
  teamId: "TEAM_ID")

# Update issue state
result = client.query(
  "mutation($id: String!, $input: IssueUpdateInput!) { issueUpdate(id: $id, input: $input) { success issue { id identifier state { name } } } }",
  { id: "ISSUE_ID", input: { stateId: "STATE_ID" } }
)

# Add comment
result = client.query(
  "mutation($input: CommentCreateInput!) { commentCreate(input: $input) { success comment { id body } } }",
  { input: { issueId: "ISSUE_ID", body: "Working on this" } }
)
```

## Development

```bash
bundle install
bundle exec rake test
```

## License

MIT
