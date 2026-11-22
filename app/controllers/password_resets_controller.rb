class PasswordResetsController < ApplicationController
  before_action :set_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  # 新しいパスワードを保存し、失敗したらエラーとフォームを再表示する
  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)
      complete_password_reset
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  # 新しいセッションでログインし、再設定トークンを無効化してプロフィールに移動する
  def complete_password_reset
    @user.remember
    reset_session
    log_in @user
    @user.update_attribute(:reset_digest, nil)
    flash[:success] = 'Password has been reset'
    redirect_to @user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # 再設定の対象ユーザーをメールアドレスで検索する
  def set_user
    @user = User.find_by(email: params[:email])
  end

  # 有効なユーザであるかどうかチェックする
  def valid_user
    redirect_to root_url unless @user&.activated? && @user.authenticated?(:reset, params[:id])
  end

  # リクエストに使われたトークンが失効していないかチェックする
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'password reset has expired'
    redirect_to new_password_reset_url
  end
end
