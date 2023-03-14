require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
end

class UsersIndexAdmin < UsersIndex
  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin

  test "should render the index page" do
    # ユーザ一覧ページが表示されていることを確認
    assert_template 'users/index'
  end

  test "should paginate users" do
    # ユーザ一覧がページネーションを利用して表示れていることを確認
    assert_select 'div.pagination'
  end

  test "should have delete links" do
    # 一般ユーザはアカウント削除用のリクエストを送るリンクが常に存在するtことを確認
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test "should be able to delete non-admin user" do
    # 一般ユーザはアカウントの消去が可能であることを確認
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "should display only activated users" do
    # 有効化されていないアカウントのページはインデックスに表示されない
    User.paginate(page: 1).first.toggle!(:activated)

    get users_path
    assigns(:users).each do |user|
      assert user.activated
    end
  end
end

class UsersNonAdminIndexTest < UsersIndex
  test "should not have delete links as non-admin" do
    # 管理者でないユーザのページにはアカウント消去用のリンクが表示されないことを確認
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
