require 'test_helper'

class UserPureFunctionsTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: 'Example User', email: 'user@example.com',
      password: 'foobar', password_confirmation: 'foobar'
    )
  end

  test 'User.digest は同じ文字列なら BCrypt で検証でき、異なる文字列なら検証に失敗する' do
    digest = BCrypt::Password.new(User.digest('foobar'))
    assert digest.is_password?('foobar')
    assert_not digest.is_password?('barfoo')
  end

  test 'User.new_token は URL セーフな文字列を返す' do
    assert_match(/\A[A-Za-z0-9_-]+\z/, User.new_token)
  end

  test 'User.new_token は呼び出しごとに異なる値を返す' do
    assert_not_equal User.new_token, User.new_token
  end

  test 'authenticated? はトークンがダイジェストと一致する場合 true を返す' do
    token = User.new_token
    @user.remember_digest = User.digest(token)
    assert @user.authenticated?(:remember, token)
  end

  test 'authenticated? はトークンがダイジェストと一致しない場合 false を返す' do
    @user.remember_digest = User.digest(User.new_token)
    assert_not @user.authenticated?(:remember, User.new_token)
  end

  test 'password_reset_expired? は送信から 2 時間以内なら false を返す' do
    freeze_time do
      @user.reset_sent_at = 1.hour.ago
      assert_not @user.password_reset_expired?
    end
  end

  test 'password_reset_expired? は送信からちょうど 2 時間の場合 false を返す' do
    freeze_time do
      @user.reset_sent_at = 2.hours.ago
      assert_not @user.password_reset_expired?
    end
  end

  test 'password_reset_expired? は送信から 2 時間を超えたら true を返す' do
    freeze_time do
      @user.reset_sent_at = 2.hours.ago - 1.second
      assert @user.password_reset_expired?
    end
  end

  test 'VALID_EMAIL_REGEX は有効なメールアドレスにマッチする' do
    %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
       first.last@foo.jp alice+bob@baz.cn].each do |address|
      assert_match User::VALID_EMAIL_REGEX, address, "#{address.inspect} はマッチするべき"
    end
  end

  test 'VALID_EMAIL_REGEX は無効なメールアドレスにマッチしない' do
    %w[user@example,com user_at_foo.org user.name@example.
       foo@bar_baz.com foo@bar+baz.com].each do |address|
      assert_no_match User::VALID_EMAIL_REGEX, address, "#{address.inspect} はマッチしないべき"
    end
  end
end
