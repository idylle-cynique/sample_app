# frozen_string_literal: true

require "rails_helper"

RSpec.describe "静的ページ", type: :request do
  BASE_TITLE = "Ruby on Rails Tutorial Sample App"

  describe "ページ表示" do
    {
      "/" => ["Welcome to the Sample App", BASE_TITLE],
      "/help" => ["Help", "Help | #{BASE_TITLE}"],
      "/about" => ["About", "About | #{BASE_TITLE}"],
      "/contact" => ["Contact", "Contact | #{BASE_TITLE}"]
    }.each do |path, (heading, title)|
      context "#{path}を取得する場合" do
        it "ページ取得時に成功応答と見出し・タイトルを返す" do
          get path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("<h1>#{heading}</h1>")
          expect(response.body).to include("<title>#{title}</title>")
        end
      end
    end
  end

  describe "ゲスト向けナビゲーション" do
    context "ホームを取得する場合" do
      it "ホーム取得時に各リンクが正しいパスを指す" do
        get root_path

        {
          "Home" => root_path,
          "Help" => help_path,
          "Log in" => login_path,
          "About" => about_path,
          "Contact" => contact_path,
          "Sign up now!" => signup_path
        }.each do |label, path|
          expect(response.body).to include(%(href="#{path}">#{label}</a>))
        end
      end
    end
  end
end
