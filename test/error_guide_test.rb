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

  def test_status_code_descriptions_are_helpful
    descriptions = Ask::Linear::Errors::STATUS_CODES
    assert_match(/OK/, descriptions[200])
    assert_match(/malformed/, descriptions[400])
    assert_match(/Unauthorized/, descriptions[401])
    assert_match(/Forbidden/, descriptions[403])
    assert_match(/Not Found/, descriptions[404])
    assert_match(/Validation/, descriptions[422])
    assert_match(/Rate limit/, descriptions[429])
    assert_match(/Server Error/, descriptions[500])
    assert_match(/Unavailable/, descriptions[503])
  end

  def test_status_code_description_returns_string
    desc = Ask::Linear::Errors.status_code_description(404)
    assert_match(/Not Found/, desc)
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
    auth_error = Ask::Linear::Errors.for("AUTHENTICATION_ERROR")
    assert_includes auth_error[:action], "settings/api"

    rate_error = Ask::Linear::Errors.for("RATE_LIMITED")
    assert_includes rate_error[:action], "100 requests"

    not_found = Ask::Linear::Errors.for("NOT_FOUND")
    assert_includes not_found[:message], "could not be found"

    forbidden = Ask::Linear::Errors.for("FORBIDDEN")
    assert_includes forbidden[:message], "does not have permission"
  end

  def test_for_all_error_codes_have_message_and_action
    Ask::Linear::Errors::ERRORS.each do |code, guidance|
      assert guidance.key?(:message), "#{code} missing :message"
      assert guidance.key?(:action), "#{code} missing :action"
    end
  end

  def test_pagination_info_is_defined
    assert Ask::Linear::Errors::PAGINATION.key?(:cursor_based)
    assert Ask::Linear::Errors::PAGINATION.key?(:page_size)
    assert Ask::Linear::Errors::PAGINATION.key?(:nodes)
    assert Ask::Linear::Errors::PAGINATION.key?(:page_info)
    assert Ask::Linear::Errors::PAGINATION.key?(:example)
  end

  def test_pagination_values_are_strings
    Ask::Linear::Errors::PAGINATION.each_value do |value|
      assert_kind_of String, value
    end
  end
end
