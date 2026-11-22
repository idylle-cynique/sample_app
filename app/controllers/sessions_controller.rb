class SessionsController < ApplicationController
  def new; end

  # 認証情報を確認し、有効化済みのユーザーをログインさせる
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
    redirect_to forwarding_url || user
  end

  def render_invalid_credentials
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
