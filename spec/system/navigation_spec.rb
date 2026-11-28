# frozen_string_literal: true

require "rails_helper"

RSpec.describe "モバイルナビゲーション", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome, screen_size: [375, 812], options: { name: :mobile_chrome }
  end

  describe "ハンバーガーメニュー" do
    context "メニューが閉じている場合" do
      it "ボタンを2回押したとき、メニューが開いて再び閉じる" do
        visit root_path

        expect(page).not_to have_css("#navbar-menu", visible: true)

        click_button "hamburger"
        expect(page).to have_css("#navbar-menu", visible: true)

        click_button "hamburger"
        expect(page).not_to have_css("#navbar-menu", visible: true)
      end
    end
  end
end
