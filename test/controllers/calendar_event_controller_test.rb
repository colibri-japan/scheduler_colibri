require 'test_helper'

class CalendarEventControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get calendar_event_new_url
    assert_response :success
  end

end
