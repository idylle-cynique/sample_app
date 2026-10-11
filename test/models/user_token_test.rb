require 'test_helper'

class UserTokenTest < ActiveSupport::TestCase
  test 'remember は remember_digest を保存して返し、remember_token で認証できる' do
    user = users(:michael)
    digest = user.remember
    assert_not_nil digest
    assert_equal digest, user.reload.remember_digest
    assert user.authenticated?(:remember, user.remember_token)
  end

  test 'forget は remember_digest を nil にする' do
    user = users(:michael)
    user.remember
    user.forget
    assert_nil user.reload.remember_digest
  end

  test 'session_token は remember_digest があればその値を返し変更しない' do
    user = users(:michael)
    user.remember
    digest = user.remember_digest
    assert_equal digest, user.session_token
    assert_equal digest, user.reload.remember_digest
  end

  test 'session_token は remember_digest が無ければ remember して新しい値を返す' do
    user = users(:michael)
    assert_nil user.remember_digest
    token = user.session_token
    assert_not_nil token
    assert_equal token, user.reload.remember_digest
  end

  test 'activate は activated を true にし activated_at を現在時刻にする' do
    inactive = users(:inactive)
    freeze_time do
      inactive.activate
      inactive.reload
      assert inactive.activated
      assert_equal Time.zone.now, inactive.activated_at
    end
  end

  test 'create_reset_digest は reset_digest を保存し reset_token で認証できる' do
    user = users(:michael)
    user.create_reset_digest
    assert_not_nil user.reload.reset_digest
    assert user.authenticated?(:reset, user.reset_token)
  end

  test 'create_reset_digest は reset_sent_at を現在時刻にする' do
    user = users(:michael)
    freeze_time do
      user.create_reset_digest
      assert_equal Time.zone.now, user.reload.reset_sent_at
    end
  end
end
