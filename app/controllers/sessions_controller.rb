class SessionsController < ApplicationController
  # ログインフォームを表示する。
  def new; end

  # 入力されたメールアドレスとパスワードを照合し、有効化済みのユーザーをログインさせる。
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if !user&.authenticate(params[:session][:password])
      render_invalid_credentials
    elsif user.activated?
      start_user_session(user)
    else
      redirect_unactivated_user
    end
  end

  # ログイン中ならセッションを解除し、ルートへ 303 でリダイレクトする。
  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private

  # セッションを更新し、ログイン状態の保持設定を反映して、保存済みの URL またはプロフィールに移動する
  def start_user_session(user)
    forwarding_url = session[:forwarding_url]
    reset_session
    params[:session][:remember_me] == '1' ? remember(user) : forget(user)
    log_in user
    flash[:success] = 'Logged in.'
    redirect_to forwarding_url || user
  end

  # 送信されたメールアドレスを保持してログインフォームを 422 で再表示する。
  def render_invalid_credentials
    @email = params[:session][:email]
    flash.now[:danger] = 'Invalid email/password combination'
    render 'new', status: :unprocessable_entity
  end

  def redirect_unactivated_user
    message = 'Account is not activated?'
    message += 'Check your email for the activation link.'
    flash[:warning] = message
    redirect_to root_url
  end
end
