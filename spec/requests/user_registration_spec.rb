# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ユーザー登録" do
  let(:valid_attributes) { attributes_for(:user) }

  describe "GET /signup" do
    it "ユーザー作成先を指すフォームに4つの入力欄を表示する" do
      get signup_path

      expect(response).to have_http_status(:ok)
      form = response.parsed_body.at_css("form[action='#{users_path}'][method='post']")
      expect(form.css("input").map { |input| input["name"] }).to include(
        "user[name]", "user[email]", "user[password]", "user[password_confirmation]"
      )
    end
  end

  describe "POST /users" do
    {
      "名前が空" => { name: "" },
      "メールアドレスが不正" => { email: "invalid" },
      "パスワードが短い" => { password: "short", password_confirmation: "short" }
    }.each do |description, invalid_attributes|
      it "#{description}の場合は登録を拒否し、エラーを表示する" do
        expect do
          post users_path, params: { user: valid_attributes.merge(invalid_attributes) }
        end.not_to change(User, :count)

        expect(response).to have_http_status(422)
        expect(response.parsed_body.css("#error_explanation li")).not_to be_empty
        expect(response.parsed_body.css(".field_with_errors")).not_to be_empty
        password_fields = response.parsed_body.css("input[type=password]")
        expect(password_fields.length).to eq(2)
        expect(password_fields.map { |field| field["value"] }).to all(be_blank)
      end
    end

    it "有効な入力で未有効化ユーザーを作成し、ゲストのままルートに戻る" do
      expect do
        post users_path, params: { user: valid_attributes }
      end.to change(User, :count).by(1)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.parsed_body.at_css(".alert-info").text).to include("activate your account")
      expect(User.find_by!(email: valid_attributes.fetch(:email))).not_to be_activated

      get users_path
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(login_path)
    end

    it "送信された管理者・有効化属性を無視して一般の未有効化ユーザーを作成する" do
      post users_path, params: { user: valid_attributes.merge(admin: true, activated: true) }

      expect(response).to redirect_to(root_path)
      user = User.find_by!(email: valid_attributes.fetch(:email))
      expect(user).not_to be_admin
      expect(user).not_to be_activated
    end
  end
end
