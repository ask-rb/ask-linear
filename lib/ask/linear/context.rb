# frozen_string_literal: true

module Ask
  module Linear
    # Human-readable description of the Linear service context.
    DESCRIPTION = "Linear — issue tracking, project management, roadmaps, sprints"

    # Base URL for Linear API documentation.
    DOCS_URL = "https://developers.linear.app/docs"

    # URL for the Linear GraphQL API schema (available via introspection).
    GRAPHQL_URL = "https://api.linear.app/graphql"

    # Credential name used with Ask::Auth.resolve.
    AUTH_NAME = :linear_api_key

    # Instructions for obtaining a Linear personal API key.
    AUTH_HOW = "https://linear.app/settings/api — generate a personal API key"

    # Gem name for the Linear API client.
    GEM_NAME = "faraday"

    # Required gem version constraint.
    GEM_VERSION = "~> 2.0"

    # URL for Faraday Ruby library documentation.
    GEM_DOCS = "https://lostisland.github.io/faraday"

    # Quick-start Ruby code snippet for agents to copy-paste.
    QUICK_START = <<~RUBY
      client = Ask::Linear.client
      # List teams
      result = client.query("query { teams { nodes { id key name } } }")
      # Get issue by ID
      result = client.query("query($id: String!) { issue(id: $id) { id identifier title description url } }", { id: "ISSUE_ID" })
      # Create issue
      result = client.query("mutation($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id identifier title url } } }", { input: { teamId: "TEAM_ID", title: "New issue", description: "Description" } })
      # List issues for a team
      result = client.query("query { team(id: \\"TEAM_ID\\") { issues { nodes { id identifier title state { name } priority } } } }")
    RUBY
  end
end
