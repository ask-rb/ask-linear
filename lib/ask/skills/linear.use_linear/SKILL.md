---
name: linear.use_linear
description: How to navigate the Linear API with GraphQL — explore the schema, build queries, paginate, and handle errors
---

Use this skill when you need to interact with Linear — managing issues, teams,
projects, sprints, or workflows. Unlike other service gems, Linear uses a raw
GraphQL API — there's no convenience client for each endpoint.

## Step 1: Get the Client

```ruby
client = Ask::Linear.client
```

This returns a `Faraday`-based client that sends HTTP POST to
`https://api.linear.app/graphql`. It expects a valid Linear API key resolved
via `Ask::Auth.resolve(:linear_api_key)`.

If you get an auth error, read `Ask::Linear::Context::AUTH_HOW` for API key setup.

## Step 2: Explore the Context

The gem ships with structured context you should reference:

```ruby
Ask::Linear::Context::DOCS_URL       # Linear developer docs
Ask::Linear::Context::GRAPHQL_URL    # GraphQL endpoint (for introspection)
Ask::Linear::Context::QUICK_START    # Query/mutation examples
```

The `QUICK_START` constant has working examples for teams, issues, and mutations.

## Step 3: Use GraphQL Introspection to Discover the Schema

Since Linear is GraphQL, you can introspect the schema to discover types,
queries, and mutations:

```ruby
# List all query fields
result = client.query("
  query {
    __schema {
      queryType {
        fields {
          name
          description
        }
      }
    }
  }
")
```

For a specific type:
```ruby
result = client.query("
  query {
    __type(name: \"Issue\") {
      name
      fields {
        name
        type {
          name
          kind
        }
      }
    }
  }
")
```

For finding all mutations:
```ruby
result = client.query("
  query {
    __schema {
      mutationType {
        fields {
          name
          args { name type { name } }
        }
      }
    }
  }
")
```

## Step 4: Common Query Patterns

**List teams:**
```ruby
client.query("query { teams { nodes { id key name } } }")
```

**List issues for a team:**
```ruby
client.query("query { team(id: \"TEAM_ID\") { issues(first: 50) { nodes { id identifier title state { name } priority } } } }")
```

**Get issue details:**
```ruby
client.query("query($id: String!) { issue(id: $id) { id identifier title description url assignee { name } } }", { id: "ISSUE_ID" })
```

**Create an issue:**
```ruby
client.query("mutation($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id identifier title url } } }", { input: { teamId: "TEAM_ID", title: "New issue", description: "Description" } })
```

**Search issues:**
```ruby
client.query("query { issues(filter: { title: { contains: \"search term\" } }) { nodes { id identifier title } } }")
```

## Step 5: Variable Syntax

Linear's GraphQL API requires exact type names. Use introspection (`__type`)
to find available input types. Variables are passed as a hash:

```ruby
client.query("query($id: String!) { issue(id: $id) { id title } }", { id: "abc123" })
```

The second argument is variables — it's passed as the second parameter to
Faraday's `post`.

## Step 6: Authentication & Common Errors

For error guidance, use:

```ruby
Ask::Linear::Errors.for("AUTHENTICATION_ERROR")
Ask::Linear::Errors.status_code_description(429)
Ask::Linear::Errors::PAGINATION
```

Common scenarios:
- **401**: API key invalid or revoked → generate new key at Linear settings
- **429**: Rate limited (100 req/min per key) → wait and retry
- **GraphQL errors**: Query returns 200 with `errors` array → check field names
- **INPUT_VALIDATION_ERROR**: Wrong argument types → check schema for exact types

## Step 7: Pagination

Linear uses cursor-based connection pagination:

```ruby
# Get first page
page = client.query("query { issues(first: 50) { nodes { id title } pageInfo { hasNextPage endCursor } } }")
# Next page:
page = client.query("query($cursor: String) { issues(first: 50, after: $cursor) { nodes { id title } pageInfo { hasNextPage endCursor } } }", { cursor: page.data.issues.pageInfo.endCursor }) while page.data.issues.pageInfo.hasNextPage
```

Use `first`/`after` for forward pagination, `last`/`before` for backward.

## Step 8: Fallback Strategy

1. Check `Ask::Linear::Context::DOCS_URL` for documentation
2. Use GraphQL introspection to discover the schema
3. Linear's API returns helpful error messages — read the `errors` array
4. For complex queries, build them incrementally — start simple, add fields
