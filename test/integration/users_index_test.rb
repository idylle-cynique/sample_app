require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index including pagination" do
    log_in_as(@admin)
    get users_path

    # ユーザー一覧ページが表示されているか確認
    assert_template 'users/index'
    assert_select 'div.pagination'
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    # ユーザ一覧ページに遷移したことを確認
    assert_template 'users/index'
    assert_select 'div.pagination'

    first_page_of_users = User.paginate(page: 1)
    # 一覧ページに各ユーザのユーザページへのリンクが、管理者でログインしている場合にはそれに加えて削除ボタンがあることを確認
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # 削除リクエストを送ると、指定したユーザが削除されて要素数が１つ減ることを確認
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
