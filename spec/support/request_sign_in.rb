# frozen_string_literal: true

module RequestSignIn
  private

  # request spec で対象ユーザーの通常のログインフローを実行する。
  def sign_in(user)
    post login_path, params: { session: { email: user.email, password: user.password } }
  end
end

RSpec.configure do |config|
  config.include RequestSignIn, type: :request
end
