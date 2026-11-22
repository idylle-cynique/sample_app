# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  describe "共通タイトルの生成" do
    context "ページタイトルが空の場合" do
      it "空文字のとき、共通タイトルを返す" do
        expect(helper.full_title("")).to eq(base_title)
      end
    end

    context "ページタイトルが指定される場合" do
      it "Helpのとき、ページ名と共通タイトルを結合して返す" do
        expect(helper.full_title("Help")).to eq("Help | #{base_title}")
      end
    end
  end
end
