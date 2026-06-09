# frozen_string_literal: true

require "faraday"
require "ask/auth"

module Ask
  module Linear
    # Returns an authenticated GraphQL client for the Linear API.
    #
    # Resolves the API key via +Ask::Auth.resolve(:linear_api_key)+ and
    # returns a +Client+ that wraps Faraday and sends GraphQL queries to
    # +https://api.linear.app/graphql+.
    #
    # Configuration:
    # - +read_timeout+: +30+ seconds
    # - +open_timeout+: +10+ seconds
    #
    # @example
    #   client = Ask::Linear.client
    #   result = client.query("query { teams { nodes { id name } } }")
    #
    # @return [Ask::Linear::Client] an authenticated GraphQL client
    # @raise [Ask::Auth::MissingCredential] if no Linear API key is configured
    # @raise [Ask::Auth::InvalidCredential] if the API key is rejected (401)
    # @raise [RuntimeError] if Linear returns GraphQL error messages
    def self.client
      api_key = Ask::Auth.resolve(:linear_api_key)
      ClientProxy.new(Client.new(api_key))
    end

    # A lightweight GraphQL client for the Linear API.
    class Client
      # Base URL for the Linear GraphQL API.
      BASE_URL = "https://api.linear.app/graphql"

      # @return [Faraday::Connection] the underlying Faraday connection
      attr_reader :connection

      # @param api_key [String] Linear personal API key
      def initialize(api_key)
        @api_key = api_key
        @connection = Faraday.new(url: BASE_URL) do |f|
          f.request :json
          f.response :json
          f.response :raise_error
          f.options.read_timeout = 30
          f.options.open_timeout = 10
          f.adapter Faraday.default_adapter
        end
      end

      # Execute a GraphQL query or mutation against the Linear API.
      #
      # @param gql [String] GraphQL query or mutation string
      # @param variables [Hash] Variables to interpolate into the query (default: {})
      # @return [Hash] Parsed response body from the Linear API
      # @raise [RuntimeError] if the API returns errors in the response body
      # @raise [Faraday::Error] if the HTTP request fails
      def query(gql, variables = {})
        response = @connection.post do |req|
          req.headers["Authorization"] = @api_key
          req.body = { query: gql, variables: variables }
        end

        body = response.body

        if body.is_a?(Hash) && body["errors"]
          messages = body["errors"].map { |e| e["message"] }.join("; ")
          raise ::RuntimeError, "Linear API error: #{messages}"
        end

        body
      end
    end

    # Proxies method calls to a +Client+, converting authentication
    # errors into +Ask::Auth::InvalidCredential+.
    class ClientProxy < BasicObject
      def initialize(client)
        @client = client
      end

      def method_missing(name, ...)
        @client.public_send(name, ...)
      rescue ::Faraday::UnauthorizedError => e
        response = e.response
        status = response.is_a?(::Hash) ? response[:status] : nil
        if status == 401
          ::Kernel.raise ::Ask::Auth::InvalidCredential, :linear_api_key
        end
        ::Kernel.raise
      rescue ::Faraday::ClientError => e
        response = e.response
        status = response.is_a?(::Hash) ? response[:status] : nil
        if status == 401
          ::Kernel.raise ::Ask::Auth::InvalidCredential, :linear_api_key
        end
        ::Kernel.raise
      end

      def respond_to_missing?(name, include_private = false)
        @client.respond_to?(name, include_private) || super
      end
    end
  end
end
