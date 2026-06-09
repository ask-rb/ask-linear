# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def setup
    Ask::Auth.reset_configuration!
  end

  def test_client_returns_client_when_api_key_available
    api_key = "lin_api_test_key_12345"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end

    client = Ask::Linear.client
    assert_kind_of Ask::Linear::Client, client
  end

  def test_client_configures_timeouts
    api_key = "lin_api_test_key"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end

    client = Ask::Linear.client
    connection = client.instance_variable_get(:@connection)
    assert_equal 30, connection.options.read_timeout
    assert_equal 10, connection.options.open_timeout
  end

  def test_client_raises_missing_credential_without_api_key
    Ask::Auth.configure do |config|
      config.providers = []
    end

    assert_raises(Ask::Auth::MissingCredential) { Ask::Linear.client }
  end

  def test_client_raises_invalid_credential_on_401
    api_key = "bad_key"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end

    client = Ask::Linear.client
    error_response = { status: 401, headers: {}, body: { errors: [{ message: "Unauthorized" }] } }
    Ask::Linear::Client.any_instance.stubs(:query).raises(Faraday::UnauthorizedError.new(error_response))

    assert_raises(Ask::Auth::InvalidCredential) { client.query("{ invalid }") }
  end

  def test_client_query_returns_data
    api_key = "lin_api_valid"
    Ask::Auth.configure do |config|
      config.providers = [->(name, user: nil) { api_key if name == "linear_api_key" }]
    end

    client = Ask::Linear.client
    response_data = { "data" => { "teams" => { "nodes" => [{ "id" => "team-1", "name" => "Engineering" }] } } }
    Ask::Linear::Client.any_instance.stubs(:query).returns(response_data)

    result = client.query("query { teams { nodes { id name } } }")
    assert_equal "Engineering", result["data"]["teams"]["nodes"][0]["name"]
  end

  def test_client_missing_credential_error_message
    Ask::Auth.configure do |config|
      config.providers = []
    end

    error = assert_raises(Ask::Auth::MissingCredential) { Ask::Linear.client }
    assert_match(/LINEAR_API_KEY/, error.message)
    assert_match(/linear_api_key/, error.message)
  end
end
