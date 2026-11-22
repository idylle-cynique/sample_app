class AccountActivationsController < ApplicationController
  # 有効なリンクでアカウントを有効化し、ログインする
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      activate_and_sign_in(user)
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end

  private

  # アカウントを有効化してログインし、プロフィールに移動する
  def activate_and_sign_in(user)
    user.activate
    log_in user
    flash[:success] = 'Account activated!'
    redirect_to user
  end
end
