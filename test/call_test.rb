require "bloc_works"
require "test/unit"
require "rack/test"

# write tests for call
class CallTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application.new
  end

  def test_call_method
    get '/'
    assert last_response.ok?
    assert last_response.header.has_value?("text/html")
  end
end
