require "test_helper"
class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end
class UsersSignupTest < UsersSignup

  test "invalid signup information" do
    # 入力内容が適切でない状態でサインアップしたときのテスト
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
        user: {
          name: "",
          email: "user@invalid",
          password: "foo",
          password_confirmation: "bar"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

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

  test "should not be activated" do
    # アカウントの有効化が未実行であることを確認
    assert_not @user.activated?
  end

  test "should not be able to log in before account activation" do
    # アカウントの有効化が完了していない場合、ログイン処理ができないことを確認
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid activation token" do
    # 不適切なアクティベーショントークンでは有効化処理を完了できないことを確認
    get edit_account_activation_path("invalid_token", email: @user.email)
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid email" do
    # 不適切なメールアドレスでは有効化処理を完了できないことを確認
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "shoud log in successfully with valid activation_token and valid email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?

    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
