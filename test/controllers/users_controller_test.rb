require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    # 会員登録ページに問題なく遷移できることを確認
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    # ログイン状態出ない場合はindexにリダイレクトが行われることを確認
    get users_path
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    # EDITアクションを実行するときは必ずログイン処理を行わせる
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    # UPDATEアクションを実行するときは必ずログイン処理を行わせる
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email
      }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "shoud not allow the admin attribute to be edited via the web" do
    # 編集権限を与えていないカラムの値はweb経由で編集できないことを確認
    log_in_as(@other_user)
    assert_not @other_user.admin?
    arg_bool = !@other_user.admin?
    patch user_path(@other_user), params: {
      user: {
        password: "password",
        password_confirmation: "password",
        admin: arg_bool
      }
    }
    assert_not_equal @other_user.admin, arg_bool
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
