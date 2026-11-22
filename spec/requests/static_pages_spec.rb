# frozen_string_literal: true

require "rails_helper"

RSpec.describe "静的ページ", type: :request do
  base_title = "Ruby on Rails Tutorial Sample App"

  describe "ページ表示" do
    {
      "/" => ["Welcome to the Sample App", base_title],
      "/help" => ["Help", "Help | #{base_title}"],
      "/about" => ["About", "About | #{base_title}"],
      "/contact" => ["Contact", "Contact | #{base_title}"]
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
      it "ホームを取得したとき、ヘッダーとフッターのリンクが正しいパスを指す" do
        get root_path

        document = response.parsed_body
        header_links = document.css("header a").map do |link|
          [link.text.strip, link["href"]]
        end
        footer_links = document.css("footer a").map do |link|
          [link.text.strip, link["href"]]
        end
        page_links = document.css("a").map do |link|
          [link.text.strip, link["href"]]
        end

        expect(header_links).to include(
          ["Home", root_path],
          ["Help", help_path],
          ["Log in", login_path]
        )
        expect(footer_links).to include(
          ["About", about_path],
          ["Contact", contact_path]
        )
        expect(page_links).to include(["Sign up now!", signup_path])
      end
    end
  end
end
