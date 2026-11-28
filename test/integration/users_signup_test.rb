require "test_helper"
class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: "Example User",
          email: "user@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: {
      user: {
        name: "Example User",
        email: "user@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }
    @user = assigns(:user)
  end

  test "should not be able to log in before account activation" do
    # アカウントの有効化が完了していない場合、ログイン処理ができないことを確認
    log_in_as(@user)
    assert_not user_logged_in?
  end

  test "should not be able to log in with invalid activation token" do
    # 不適切なアクティベーショントークンでは有効化処理を完了できないことを確認
    get edit_account_activation_path("invalid_token", email: @user.email)
    assert_not user_logged_in?
  end

  test "should not be able to log in with invalid email" do
    # 不適切なメールアドレスでは有効化処理を完了できないことを確認
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not user_logged_in?
  end

  test "shoud log in successfully with valid activation_token and valid email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?

    follow_redirect!
    assert_template 'users/show'
    assert user_logged_in?
  end
end
