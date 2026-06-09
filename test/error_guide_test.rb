# frozen_string_literal: true

require_relative "test_helper"

class ErrorGuideTest < Minitest::Test
  def test_rate_limit_authenticated
    assert_includes Ask::Linear::Errors::RATE_LIMIT[:authenticated], "100"
  end

  def test_rate_limit_has_error_class
    assert_includes Ask::Linear::Errors::RATE_LIMIT[:error_class], "429"
  end

  def test_rate_limit_has_action
    assert Ask::Linear::Errors::RATE_LIMIT[:action]
  end

  def test_status_codes_cover_common_codes
    [200, 400, 401, 403, 404, 422, 429, 500, 503].each do |code|
      assert Ask::Linear::Errors::STATUS_CODES.key?(code), "Missing status code #{code}"
    end
  end

  def test_status_code_description_returns_string
    desc = Ask::Linear::Errors.status_code_description(401)
    assert_match(/Unauthorized/, desc)
  end

  def test_status_code_description_returns_nil_for_unknown
    assert_nil Ask::Linear::Errors.status_code_description(999)
  end

  def test_errors_cover_common_graphql_errors
    %w[
      AUTHENTICATION_ERROR
      FORBIDDEN
      NOT_FOUND
      RATE_LIMITED
      INPUT_VALIDATION_ERROR
      DUPLICATE_INPUT
      INTERNAL_ERROR
      USER_SUSPENDED
      WORKSPACE_SUSPENDED
    ].each do |code|
      assert Ask::Linear::Errors::ERRORS.key?(code), "Missing error code #{code}"
    end
  end

  def test_for_returns_guidance
    guidance = Ask::Linear::Errors.for("AUTHENTICATION_ERROR")
    assert guidance.key?(:message)
    assert guidance.key?(:action)
  end

  def test_for_returns_nil_for_unknown
    assert_nil Ask::Linear::Errors.for("SOME_UNKNOWN_ERROR")
  end

  def test_error_messages_are_helpful
    error = Ask::Linear::Errors.for("AUTHENTICATION_ERROR")
    assert_includes error[:action], "settings/api"
  end

  def test_pagination_info_is_defined
    assert Ask::Linear::Errors::PAGINATION.key?(:cursor_based)
    assert Ask::Linear::Errors::PAGINATION.key?(:page_size)
    assert Ask::Linear::Errors::PAGINATION.key?(:nodes)
    assert Ask::Linear::Errors::PAGINATION.key?(:page_info)
    assert Ask::Linear::Errors::PAGINATION.key?(:example)
  end
end
