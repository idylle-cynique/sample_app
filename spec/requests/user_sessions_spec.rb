# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ユーザーセッション" do
  let!(:user) { create(:user, activated: true) }

  describe "GET /login" do
    it "ログインフォームと Remember me の選択肢を表示する" do
      get login_path

      expect(response).to have_http_status(:ok)
      form = response.parsed_body.at_css("form[action='#{login_path}'][method='post']")
      expect(form.css("input").map { |input| input["name"] }).to include(
        "session[email]", "session[password]", "session[remember_me]"
      )
    end
  end

  describe "POST /login" do
    it "本人のプロフィールへ進み、認証済みメニューと成功メッセージを表示する" do
      post login_path, params: { session: { email: user.email, password: user.password } }

      expect(response).to redirect_to(user_path(user))
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css(".alert-success").text).to eq("Logged in.")

      links = response.parsed_body.css("header a").to_h { |link| [link.text.strip, link["href"]] }
      expect(links).to include(
        "Users" => users_path,
        "Profile" => user_path(user),
        "Settings" => edit_user_path(user),
        "Log out" => logout_path
      )
      expect(links).not_to have_key("Log in")
      expect(response.parsed_body.css("a[href='#{signup_path}']")).to be_empty
    end

    it "メールアドレスの大小文字が違っても同じユーザーとして認証する" do
      post login_path, params: { session: { email: user.email.upcase, password: user.password } }

      expect(response).to redirect_to(user_path(user))
      get edit_user_path(user)
      expect(response).to have_http_status(:ok)
    end

    it "未有効化のユーザーは正しいパスワードでもログインできない" do
      inactive = create(:user, activated: false)

      post login_path, params: { session: { email: inactive.email, password: inactive.password, remember_me: "1" } }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.parsed_body.at_css(".alert-warning").text).to include("Account is not activated")
      expect(response.parsed_body.at_css("header a[href='#{login_path}']")).to be_present
      expect(inactive.reload).to have_attributes(remember_digest: nil, session_token: nil)

      get users_path
      expect(response).to redirect_to(login_path)
    end

    %w[未登録メール 誤ったパスワード].each do |failure|
      it "#{failure}の場合はメール欄を保持し、エラーをその応答だけに表示する" do
        email = failure == "未登録メール" ? "unknown@example.com" : user.email

        post login_path, params: { session: { email: email, password: "wrong password" } }

        expect(response).to have_http_status(422)
        expect(response.parsed_body.at_css("#session_email")["value"]).to eq(email)
        expect(response.parsed_body.at_css("#session_password")["value"]).to be_blank
        expect(response.parsed_body.at_css(".alert-danger").text).to include("Invalid email/password combination")

        get root_path
        expect(response.parsed_body.at_css(".alert-danger")).to be_nil
        expect(response.parsed_body.at_css("header a[href='#{login_path}']")).to be_present
        expect(user.reload.session_token).to be_nil
      end
    end
  end

  describe "Remember me" do
    it "オンの場合は期限を持つ Cookie と認証用のダイジェストを設定する" do
      post login_path, params: { session: { email: user.email, password: user.password, remember_me: "1" } }

      expect(response).to redirect_to(user_path(user))
      expect(cookies["user_id"]).to be_present
      expect(cookies["remember_token"]).to be_present
      expect(user.reload.authenticated?(:remember, cookies["remember_token"])).to be(true)
      expect(user.session_token).not_to eq(user.remember_digest)
      cookie_headers = Array(response.headers.fetch("set-cookie")).flat_map(&:lines)
      expect(cookie_headers).to include(match(/\Auser_id=.*; expires=/i), match(/\Aremember_token=.*; expires=/i))
    end

    it "オフの場合は通常セッションで認証し、記憶ダイジェストを作らない" do
      post login_path, params: { session: { email: user.email, password: user.password, remember_me: "0" } }

      expect(response).to redirect_to(user_path(user))
      expect(cookies["user_id"]).to be_blank
      expect(cookies["remember_token"]).to be_blank
      expect(user.reload.remember_digest).to be_nil
      expect(user.session_token).to be_present
      get users_path
      expect(response).to have_http_status(:ok)
    end

    it "オンでログインした後にオフでログインすると以前の記憶情報を解除する" do
      credentials = { email: user.email, password: user.password }
      post login_path, params: { session: credentials.merge(remember_me: "1") }
      previous_session_token = user.reload.session_token
      previous_remember_token = cookies["remember_token"]
      expect(previous_remember_token).to be_present

      post login_path, params: { session: credentials.merge(remember_me: "0") }

      expect(cookies["user_id"]).to be_blank
      expect(cookies["remember_token"]).to be_blank
      expect(user.reload.remember_digest).to be_nil
      expect(user.session_token).not_to eq(previous_session_token)
      expect(user.authenticated?(:remember, previous_remember_token)).to be(false)
    end
  end

  describe "DELETE /logout" do
    it "通常セッションと永続 Cookie を解除してルートに戻る" do
      post login_path, params: { session: { email: user.email, password: user.password, remember_me: "1" } }

      delete logout_path

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
      expect(cookies["user_id"]).to be_blank
      expect(cookies["remember_token"]).to be_blank
      expect(user.reload).to have_attributes(remember_digest: nil, session_token: nil)
      get users_path
      expect(response).to redirect_to(login_path)
    end

    it "ログアウトを再度要求してもゲストのままルートに戻る" do
      delete logout_path

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end
  end
end
