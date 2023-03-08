require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: "",
        email: "foo@invalid",
        password: "foo",
        password_confirmation: "bar"
      }
    }

    assert_template 'users/edit'
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {
      user: {
        name: "Foo Bar",
        email: "foo@bar.com",
        password: "",
        password_confirmation: ""
      }
    }

    # 適切な入力を行った場合、フラッシュメッセージは表示されず、ユーザページへリダイレクトされる
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload # ユーザモデルを再度参照・更新

    # 更新処理を行ったことで、入力したデータが実際のモデルに反映されていることを確認
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  test 'successful edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: "",
        password_confirmation: ""
      }
    }

    # 正しくリクエストが送信されたことを確認する
    assert_not flash.empty?
    assert_redirected_to @user

    # ユーザ情報がリクエストの送信内容通りに変更されていることを確認
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
