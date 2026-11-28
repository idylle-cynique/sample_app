module SessionsHelper
  # ユーザーのセッションを更新する。remember_me が true の場合だけ永続 Cookie を発行する。
  def log_in(user, remember_me: false)
    user.with_lock do
      user.update_attribute!(:session_token, User.new_token)
      remember_me ? user.remember : user.forget
    end

    remember_me ? write_remember_cookies(user) : delete_remember_cookies
    store_session(user)
  end

  # セッションか永続 Cookie が有効なら対応するユーザーを返し、無効なら nil を返す。
  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      user if user&.session_token.present? && session[:session_token] == user.session_token
    elsif (user_id = cookies.encrypted[:user_id])
      restore_session(user_id)
    end
  end

  # 指定したユーザーが現在認証されている本人かどうかを返す。
  def current_user?(user)
    user.present? && user == current_user
  end

  # 現在のリクエストが認証済みかどうかを返す。
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーのトークンを失効させ、ブラウザーの認証状態を消去する。
  def log_out
    user = current_user
    return unless user

    user.with_lock do
      if user.session_token == session[:session_token]
        user.update_attribute!(:session_token, nil)
        user.forget
      end
    end

    delete_remember_cookies
    reset_session
  end

  # GET の遷移先をログイン後の転送用に保存する。
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

  # 照合済みのユーザーの ID とセッショントークンを保存する。
  def store_session(user)
    session[:user_id] = user.id
    session[:session_token] = user.session_token
  end

  # 記憶トークンを照合し、既存のセッショントークンで復元したユーザーを返す。
  def restore_session(user_id)
    user = User.find_by(id: user_id)
    return unless user&.session_token.present? && user.authenticated?(:remember, cookies[:remember_token])

    store_session(user)
    user
  end

  def write_remember_cookies(user)
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def delete_remember_cookies
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end
