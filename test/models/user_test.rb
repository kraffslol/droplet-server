require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should create a user with a hashed password" do
    u = User.create(:login => "homer",
                    :password => "1234",
                    :password_confirmation => "1234")
    u.reload # (make sure it saved!)
    assert_not_nil u.hashed_password
  end

  test "given a user named homer with a password of 1234, he should be authenticated with 'homer' and '1234' " do
    User.create(:login => "homer",
                :password => "1234",
                :password_confirmation => "1234")
    assert User.authenticated?("homer", "1234")
  end
end
