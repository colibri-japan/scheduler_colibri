require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save user with existing email" do
    user = User.new(email: 'remi.daste@keio.jp', name: 'ユーザー１', kana: 'ユーザー１', password: 'password', password_confirmation: 'password')
    assert_not user.save, 'Saved a user with existing email address'
  end
end
