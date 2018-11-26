require 'test_helper'

class ScanControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get scan_index_url
    assert_response :success
  end

  test "should get new" do
    get scan_new_url
    assert_response :success
  end

  test "should get create" do
    get scan_create_url
    assert_response :success
  end

  test "should get edit" do
    get scan_edit_url
    assert_response :success
  end

  test "should get update" do
    get scan_update_url
    assert_response :success
  end

  test "should get destroy" do
    get scan_destroy_url
    assert_response :success
  end

end
