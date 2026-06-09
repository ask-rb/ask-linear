# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def build_test_client(api_key)
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end
    Ask::Linear.client
  end

  def raw_client(api_key)
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end
    Ask::Linear::Client.new(api_key)
  end

  def test_client_returns_client_when_api_key_available
    client = build_test_client("lin_api_test_key_12345")
    assert_kind_of Ask::Linear::Client, client
  end

  def test_client_configures_timeouts
    connection = build_test_client("lin_api_test_key").instance_variable_get(:@connection)
    assert_equal 30, connection.options.read_timeout
    assert_equal 10, connection.options.open_timeout
  end

  def test_client_configures_retry_middleware
    connection = build_test_client("lin_api_test_key").instance_variable_get(:@connection)
    retry_handler = connection.builder.handlers.find { |h| h.klass == Faraday::Retry::Middleware }
    assert retry_handler, "Retry middleware not configured"
  end

  def test_client_actual_query_returns_data
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("/graphql") do
      [200, { "Content-Type" => "application/json" },
       { "data" => { "teams" => { "nodes" => [{ "id" => "team-1", "name" => "Engineering" }] } } }.to_json]
    end

    c = raw_client("lin_api_test")
    test_conn = Faraday.new(url: "https://api.linear.app/graphql") do |f|
      f.request :json; f.response :json; f.adapter :test, stubs
    end
    c.instance_variable_set(:@connection, test_conn)
    client = Ask::Linear::ClientProxy.new(c)

    result = client.query("query { teams { nodes { id name } } }")
    assert_equal "Engineering", result["data"]["teams"]["nodes"][0]["name"]
  end

  def test_client_actual_query_raises_on_graphql_errors
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("/graphql") do
      [200, { "Content-Type" => "application/json" },
       { "errors" => [{ "message" => "Field 'foo' doesn't exist" }] }.to_json]
    end

    c = raw_client("lin_api_test")
    test_conn = Faraday.new(url: "https://api.linear.app/graphql") do |f|
      f.request :json; f.response :json; f.adapter :test, stubs
    end
    c.instance_variable_set(:@connection, test_conn)
    client = Ask::Linear::ClientProxy.new(c)

    error = assert_raises(RuntimeError) { client.query("{ invalid }") }
    assert_match(/Linear API error/, error.message)
  end

  def test_client_raises_invalid_credential_on_401
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("/graphql") { [401, {}, ""] }

    c = raw_client("bad_key")
    test_conn = Faraday.new(url: "https://api.linear.app/graphql") do |f|
      f.request :json; f.response :json; f.response :raise_error; f.adapter :test, stubs
    end
    c.instance_variable_set(:@connection, test_conn)
    client = Ask::Linear::ClientProxy.new(c)

    assert_raises(Ask::Auth::InvalidCredential) { client.query("{ invalid }") }
  end

  def test_client_re_raises_non_401_errors
    stubs = Faraday::Adapter::Test::Stubs.new
    stubs.post("/graphql") { [403, {}, ""] }

    c = raw_client("valid_key")
    test_conn = Faraday.new(url: "https://api.linear.app/graphql") do |f|
      f.request :json; f.response :json; f.response :raise_error; f.adapter :test, stubs
    end
    c.instance_variable_set(:@connection, test_conn)
    client = Ask::Linear::ClientProxy.new(c)

    assert_raises(Faraday::ForbiddenError) { client.query("{ valid }") }
  end

  def test_client_raises_missing_credential_without_api_key
    Ask::Auth.configure { |c| c.providers = [] }
    assert_raises(Ask::Auth::MissingCredential) { Ask::Linear.client }
  end

  def test_client_missing_credential_error_message
    Ask::Auth.configure { |c| c.providers = [] }
    error = assert_raises(Ask::Auth::MissingCredential) { Ask::Linear.client }
    assert_match(/LINEAR_API_KEY/, error.message)
    assert_match(/linear_api_key/, error.message)
  end

  def test_client_rejects_non_string_gql
    client = Ask::Linear::ClientProxy.new(raw_client("lin_api_valid"))
    error = assert_raises(ArgumentError) { client.query(nil) }
    assert_match(/gql must be a String/, error.message)
  end

  def test_client_rejects_non_hash_variables
    client = Ask::Linear::ClientProxy.new(raw_client("lin_api_valid"))
    error = assert_raises(ArgumentError) { client.query("{ teams }", "not_a_hash") }
    assert_match(/variables must be a Hash/, error.message)
  end

  def test_client_respond_to_missing
    client = build_test_client("lin_api_test")
    assert client.respond_to?(:query)
    assert client.respond_to?(:connection)
    refute client.respond_to?(:nonexistent_method)
  end
end
