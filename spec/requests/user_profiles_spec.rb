# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ユーザープロフィール" do
  let(:user) { create(:user, activated: true) }
  let(:valid_updates) { { name: "Updated User", email: "updated@example.com" } }

  describe "GET /users/:id" do
    it "ゲストにプロフィールの名前と Gravatar を表示する" do
      get user_path(user)

      expect(response).to have_http_status(:ok)
      heading = response.parsed_body.at_css(".user_info h1")
      expect(heading.text.strip).to eq(user.name)
      expect(heading.at_css("img.gravatar")).to be_present
    end

    it "存在しないユーザーは 404 を返す" do
      missing_id = user.id + 1

      get user_path(missing_id), env: { "action_dispatch.show_exceptions" => :rescuable }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "編集・更新の認可" do
    context "ゲストの場合" do
      it "編集画面へのアクセスをログインへ誘導する" do
        get edit_user_path(user)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(login_path)
      end

      it "更新をログインへ誘導し、ユーザー情報を維持する" do
        expect do
          patch user_path(user), params: { user: valid_updates }
        end.not_to(change { user.reload.attributes })

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(login_path)
      end

      it "最初に要求した編集 URL へ認証後に戻る" do
        get edit_user_path(user)

        sign_in(user)

        expect(response).to redirect_to(edit_user_path(user))
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "更新リクエストの URL をログイン後の転送先にしない" do
        other_user = create(:user, activated: true)
        patch user_path(other_user), params: { user: valid_updates }

        sign_in(user)

        expect(response).to redirect_to(user_path(user))
      end
    end

    context "別ユーザーの場合" do
      before do
        sign_in(create(:user, activated: true))
      end

      it "編集画面を拒否しルートへ誘導する" do
        get edit_user_path(user)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)
      end

      it "更新を拒否し対象の DB 値を維持する" do
        expect do
          patch user_path(user), params: { user: valid_updates }
        end.not_to(change { user.reload.attributes })

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "本人による編集・更新" do
    before do
      sign_in(user)
    end

    it "本人の値を含む編集フォームを表示する" do
      get edit_user_path(user)

      expect(response).to have_http_status(:ok)
      form = response.parsed_body.at_css("form[action='#{user_path(user)}']")
      expect(form.at_css("input[name='_method']")["value"]).to eq("patch")
      expect(form.at_css("input[name='user[email]']")["value"]).to eq(user.email)
    end

    it "パスワード欄が空なら名前とメールだけを更新する" do
      patch user_path(user), params: { user: valid_updates.merge(password: "", password_confirmation: "") }

      expect(response).to redirect_to(user_path(user))
      expect(user.reload).to have_attributes(valid_updates)
      expect(user.authenticate(user.password)).to eq(user)
    end

    it "パスワードを変更し、古いパスワードを無効にする" do
      old_password = user.password
      new_password = "new password"

      patch user_path(user), params: { user: { password: new_password, password_confirmation: new_password } }

      expect(response).to redirect_to(user_path(user))
      expect(user.reload.authenticate(new_password)).to eq(user)
      expect(user.authenticate(old_password)).to be(false)
    end

    {
      "不正なメール" => { email: "invalid" },
      "確認が一致しないパスワード" => { password: "new password", password_confirmation: "different" }
    }.each do |failure, invalid_updates|
      it "#{failure}での更新を拒否してフォームとエラーを表示する" do
        expect do
          patch user_path(user), params: { user: valid_updates.merge(invalid_updates) }
        end.not_to(change { user.reload.attributes })

        expect(response).to have_http_status(422)
        expect(response.parsed_body.at_css("form[action='#{user_path(user)}']")).to be_present
        expect(response.parsed_body.css("#error_explanation li")).not_to be_empty
      end
    end

    it "更新に含めた管理者属性を無視する" do
      patch user_path(user), params: { user: valid_updates.merge(admin: true) }

      expect(response).to redirect_to(user_path(user))
      expect(user.reload).to have_attributes(admin: false, name: valid_updates.fetch(:name))
    end
  end
end
