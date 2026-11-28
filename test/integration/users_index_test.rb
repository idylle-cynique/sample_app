require "test_helper"

class UsersIndexAdminTest < ActionDispatch::IntegrationTest
  def setup
    log_in_as(users(:michael))
    get users_path
  end

  test "should paginate users" do
    # ユーザ一覧がページネーションを利用して表示れていることを確認
    assert_select 'div.pagination'
    # 先頭ページでは「前へ」が無効、「次へ」が aria-label 付きで有効であることを確認
    assert_select 'li.prev.disabled'
    assert_select 'li.next a[rel=next][aria-label=?]', 'Next page'
  end
end
