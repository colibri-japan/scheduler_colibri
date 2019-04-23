require 'test_helper'

class BonusesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bonuses_new_url
    assert_response :success
  end

end
