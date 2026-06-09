# frozen_string_literal: true

module Ask
  module Linear
    # Structured error knowledge for AI agents working with the Linear API.
    #
    # Provides human-readable guidance for common HTTP status codes, rate
    # limiting, authentication errors, and GraphQL error extensions
    # encountered when using the Linear GraphQL API.
    module Errors
      # Rate limit information.
      #
      # - Authenticated requests: 100 requests per minute per API key
      #
      # When rate-limited, Linear returns a 429 status code. The agent
      # should wait and retry.
      RATE_LIMIT = {
        authenticated: "100 requests per minute per API key",
        error_class: "Faraday::ClientError (HTTP 429)",
        action: "Wait for the rate limit window and retry. Linear uses a sliding window rate limiter."
      }.freeze

      # Common HTTP status codes returned by the Linear GraphQL API and how to handle them.
      #
      # Linear wraps most errors in GraphQL error responses (HTTP 200 with errors body),
      # but some authentication and rate-limit errors come through as HTTP status codes.
      STATUS_CODES = {
        200 => "OK — The request succeeded. Check the response body for GraphQL errors.",
        400 => "Bad Request — The GraphQL query is malformed or invalid variables.",
        401 => "Unauthorized — API key is missing, invalid, or revoked. Re-authenticate.",
        403 => "Forbidden — API key lacks access to the requested resource.",
        404 => "Not Found — The requested resource does not exist.",
        422 => "Unprocessable Entity — Validation failed. Check request parameters.",
        429 => "Too Many Requests — Rate limit exceeded. Wait before retrying.",
        500 => "Internal Server Error — Linear server issue. Retry with backoff.",
        503 => "Service Unavailable — Linear is temporarily unavailable. Retry later."
      }.freeze

      # Pagination guidance for the Linear GraphQL API.
      PAGINATION = {
        cursor_based: "Linear uses cursor-based pagination with first/after or last/before arguments.",
        page_size: "Use the 'first' argument to control page size (default: 50, max: 100).",
        nodes: "List fields return a connection with 'nodes', 'pageInfo', and 'edges'.",
        page_info: "Check pageInfo.hasNextPage and pageInfo.hasPreviousPage for more pages.",
        example: 'query { issues(first: 50, after: "cursor") { nodes { id title } pageInfo { hasNextPage endCursor } } }'
      }.freeze

      # Map of common GraphQL error messages to human-readable guidance.
      #
      # Linear returns errors in the GraphQL format: +{ "errors": [{ "message": "...", "extensions": { ... } }] }+
      ERRORS = {
        "AUTHENTICATION_ERROR" => {
          message: "The API key is missing, invalid, or has been revoked.",
          action: "Generate a new API key at https://linear.app/settings/api and update your credentials."
        },
        "FORBIDDEN" => {
          message: "Your API key does not have permission to access this resource.",
          action: "Check that your API key has the necessary scopes. You may need an admin to grant access."
        },
        "NOT_FOUND" => {
          message: "The requested resource could not be found.",
          action: "Verify the ID or identifier is correct. Resources may have been deleted or you may not have access."
        },
        "RATE_LIMITED" => {
          message: "API rate limit exceeded.",
          action: "Wait before retrying. Linear allows 100 requests per minute per API key."
        },
        "INPUT_VALIDATION_ERROR" => {
          message: "The input data failed validation.",
          action: "Check required fields, data types, and constraints. Linear returns detailed error messages."
        },
        "DUPLICATE_INPUT" => {
          message: "A resource with the same input data already exists.",
          action: "Check for existing resources before creating new ones with duplicate fields."
        },
        "INTERNAL_ERROR" => {
          message: "Linear encountered an internal server error.",
          action: "Retry with exponential backoff. If the issue persists, check https://linearstatus.com."
        },
        "USER_SUSPENDED" => {
          message: "The authenticated user account has been suspended.",
          action: "Contact your Linear workspace administrator to resolve the suspension."
        },
        "WORKSPACE_SUSPENDED" => {
          message: "The Linear workspace has been suspended or deactivated.",
          action: "Contact your Linear workspace administrator or check billing status."
        }
      }.freeze

      # Look up guidance for a GraphQL error extension code.
      #
      # @param error_code [String] The error extension code (e.g., "AUTHENTICATION_ERROR")
      # @return [Hash, nil] A hash with +:message+ and +:action+ keys, or nil if unknown
      def self.for(error_code)
        ERRORS[error_code]
      end

      # Describe an HTTP status code.
      #
      # @param code [Integer] HTTP status code
      # @return [String, nil] Description of the status code
      def self.status_code_description(code)
        STATUS_CODES[code]
      end
    end
  end
end
