# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  let(:user) { create(:user, password: "password") }

  describe "パスワード認証" do
    it "正しいパスワードで本人を返す" do
      expect(user.authenticate("password")).to eq(user)
    end

    it "誤ったパスワードを拒否する" do
      expect(user.authenticate("incorrect")).to be(false)
    end
  end

  describe "記憶トークン認証" do
    it "ダイジェストを持たないときは認証に失敗する" do
      expect(user.authenticated?(:remember, "token")).to be(false)
    end

    it "生トークンと異なるダイジェストを保存し、正しいトークンを認証する" do
      user.remember
      token = user.remember_token
      user.reload

      expect(user.remember_digest).to be_present
      expect(user.remember_digest).not_to eq(token)
      expect(user.authenticated?(:remember, token)).to be(true)
    end

    it "記憶ダイジェストがあっても異なるトークンでは認証に失敗する" do
      user.remember

      expect(user.authenticated?(:remember, "different")).to be(false)
    end

    it "記憶の解除で以前のトークンが無効になる" do
      user.remember
      token = user.remember_token
      user.forget

      expect(user.reload.remember_digest).to be_nil
      expect(user.authenticated?(:remember, token)).to be(false)
    end
  end
end
