require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do

    # 1. ログイン用のパスを開く
    get login_path

    # 2. ログイン用のページが開かれたことを確認
    assert_template 'sessions/new'

    # 3. 意図的に意図的に無効なparamsを使ってpostリクエストを送る
    post login_path, params: { session: { email: "", password: "" } }

    # 4. セッションコントローラが正しいステータスを返すことを確認する
    assert_response :unprocessable_entity

    # 5.　ページが移動せずそのままであることを確認のうえ、フラッシュメッセージがたしかに表示されていることを確認
    assert_template 'sessions/new'
    assert_not flash.empty?

    # 6. 別のページに移動する
    get root_path

    # 7. 移動先のページでフラッシュメッセージが表示されていないことを確認する
    assert flash.empty?
  end
end
