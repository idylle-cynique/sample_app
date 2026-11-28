# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ユーザー一覧と削除" do
  let(:user) { create(:user, activated: true) }
  let(:admin) { create(:user, activated: true, admin: true) }

  describe "GET /users" do
    it "ゲストをログインへ誘導する" do
      get users_path

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(login_path)
    end

    it "有効化済みユーザーを重複や欠落なくページに分ける" do
      inactive = create(:user, activated: false)
      users = [user] + create_list(:user, User.per_page, activated: true)
      sign_in(user)

      get users_path

      expect(response).to have_http_status(:ok)
      first_page = response.parsed_body.css(".users > li > a").map { |link| link["href"] }
      next_page = response.parsed_body.at_css(".pagination a[rel=next]")["href"]
      expect(first_page).to eq(users.first(User.per_page).map { |member| user_path(member) })

      get next_page

      expect(response).to have_http_status(:ok)
      second_page = response.parsed_body.css(".users > li > a").map { |link| link["href"] }
      expect(second_page).to eq([user_path(users.last)])
      expect(first_page + second_page).not_to include(user_path(inactive))
    end

    it "管理者には他ユーザーの削除リンクだけを表示する" do
      sign_in(admin)
      member = create(:user, activated: true)

      get users_path

      expect(response).to have_http_status(:ok)
      delete_links = response.parsed_body.css(".users [data-turbo-method='delete']").map { |link| link["href"] }
      expect(delete_links).to eq([user_path(member)])
    end

    it "一般ユーザーには削除リンクを表示しない" do
      create(:user, activated: true)
      sign_in(user)

      get users_path

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.css(".users [data-turbo-method='delete']")).to be_empty
    end
  end

  describe "DELETE /users/:id" do
    let!(:target) { create(:user, activated: true) }

    it "管理者は対象ユーザーを削除して一覧へ戻る" do
      sign_in(admin)

      expect do
        delete user_path(target)
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(users_path)
      expect(User.exists?(target.id)).to be(false)
      expect(User.exists?(admin.id)).to be(true)
    end

    it "一般ユーザーによる削除を拒否してルートへ誘導する" do
      sign_in(user)

      expect do
        delete user_path(target)
      end.not_to change(User, :count)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
      expect(User.exists?(target.id)).to be(true)
    end

    it "ゲストによる削除を拒否してログインへ誘導する" do
      expect do
        delete user_path(target)
      end.not_to change(User, :count)

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(login_path)
      expect(User.exists?(target.id)).to be(true)
    end
  end
end
