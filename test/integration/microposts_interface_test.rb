require "test_helper"

class MicropostsInterface < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostsInterface
  test "should paginate microposts" do
    # ページネーションが行われていることを確認
    get root_path
    assert_select 'div.pagination'
  end

  test "should show errors but not create microposts on invalid submission" do
    # 不適切な入力(空文)を行うと投稿処理が行われないことを確認
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
  end

  test "should create a micropost on valid submission" do
    # 適切に入力を行うとマイクロポストを投稿することが出来ることを確認
    content = "This is micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  test "should be able to delete own micropost" do
    # 自身で投稿したマイクロソフトについては削除可能であることを確認
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
  end

  test "should not have delete links on other user's profile page" do
    # 他のユーザページおよびページ上のマイクロソフトについては削除リンクが存在しないことを確認
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MicropostSidebarTest < MicropostsInterface
  test "should display the right micropost count" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  test "should user proper pluralization for zero microposts" do
    log_in_as(users(:malory))
    get root_path
    assert_match "0 microposts", response.body
  end

  test "should user proper pluralization for one micropost" do
    log_in_as(users(:lana))
    get root_path
    assert_match "1 micropost", response.body
  end
end

class ImageUploadTest < MicropostsInterface
  test "should have a file input field for images" do
    # 画像アップロード用のinputタグが存在することを確認
    get root_path
    assert_select 'input[type=file]'
  end

  test "should be able to attach an imgae" do
    cont = "This micropost really ties the room together."
    img = fixture_file_upload('kitten.jpg', 'image/jpeg')
    post microposts_path, params: { micropost: { content: cont, image: img } }
    assert assigns(:micropost).image.attached?
  end
end
