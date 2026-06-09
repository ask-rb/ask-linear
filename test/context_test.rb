# frozen_string_literal: true

require_relative "test_helper"

class ContextTest < Minitest::Test
  def test_description_is_defined
    assert_match(/Linear/, Ask::Linear::DESCRIPTION)
  end

  def test_docs_url_is_defined
    assert Ask::Linear::DOCS_URL.start_with?("https://developers.linear.app")
  end

  def test_graphql_url_is_defined
    assert_equal "https://api.linear.app/graphql", Ask::Linear::GRAPHQL_URL
  end

  def test_auth_name_is_linear_api_key
    assert_equal :linear_api_key, Ask::Linear::AUTH_NAME
  end

  def test_auth_how_is_defined
    assert_includes Ask::Linear::AUTH_HOW, "settings/api"
  end

  def test_gem_name_is_defined
    assert_equal "faraday", Ask::Linear::GEM_NAME
  end

  def test_gem_version_is_defined
    assert_match(/~> 2\.0/, Ask::Linear::GEM_VERSION)
  end

  def test_gem_docs_is_defined
    assert Ask::Linear::GEM_DOCS.start_with?("https://lostisland.github.io/faraday")
  end

  def test_quick_start_is_defined
    assert_includes Ask::Linear::QUICK_START, "Ask::Linear.client"
  end

  def test_quick_start_includes_common_operations
    %w[teams issueCreate].each do |method|
      assert_includes Ask::Linear::QUICK_START, method
    end
  end
end
