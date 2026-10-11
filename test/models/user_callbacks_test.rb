require 'test_helper'

class UserCallbacksTest < ActiveSupport::TestCase
  test 'before_create は新規作成時に activation_digest を設定する' do
    user = User.create!(
      name: 'Example User', email: 'user@example.com',
      password: 'foobar', password_confirmation: 'foobar'
    )
    assert_not_nil user.reload.activation_digest
    assert user.authenticated?(:activation, user.activation_token)
  end

  test 'before_create は既存ユーザーの更新では activation_digest を変更しない' do
    user = users(:michael)
    user.update_column(:activation_digest, User.digest(User.new_token))
    assert_no_changes -> { user.reload.activation_digest } do
      user.update!(name: 'Updated Name')
    end
  end

  test 'ユーザーを削除すると、そのユーザーのマイクロポストも削除される' do
    michael = users(:michael)
    assert_difference 'Micropost.count', -michael.microposts.count do
      michael.destroy
    end
  end

  test 'ユーザーを削除すると、フォロー・被フォローのリレーションシップも削除される' do
    michael = users(:michael)
    count = michael.active_relationships.count + michael.passive_relationships.count
    assert_difference 'Relationship.count', -count do
      michael.destroy
    end
  end
end
