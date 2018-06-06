require 'test_helper'

class NursesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get nurses_index_url
    assert_response :success
  end

end
