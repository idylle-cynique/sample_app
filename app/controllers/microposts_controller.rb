class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy]

  # ログイン中のユーザーの投稿を保存し、失敗したらエラーとフィードを再表示する
  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url
    else
      render_feed_with_errors
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    redirect_back_or_to(root_url, status: :see_other)
  end

  private

  # 保存に失敗した投稿と、指定されたページのフィードを表示する
  def render_feed_with_errors
    @feed_items = current_user.feed.paginate(page: params[:page])
    render 'static_pages/home', status: :unprocessable_entity
  end

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
  end
end
