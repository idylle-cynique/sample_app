# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ブラウザーでのユーザー登録" do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "不正入力の訂正後に登録でき、登録直後はログインしていない" do
    visit signup_path
    click_button "Create my account"

    expect(page).to have_css("#error_explanation")
    expect(User.count).to eq(0)

    fill_in "user_name", with: "New User"
    fill_in "user_email", with: "new@example.com"
    fill_in "user_password", with: "valid password"
    fill_in "user_password_confirmation", with: "valid password"
    click_button "Create my account"

    expect(page).to have_current_path(root_path)
    expect(page).to have_css(".alert-info", text: "activate your account")
    expect(page).to have_link("Log in", href: login_path)
    expect(User.find_by!(email: "new@example.com")).not_to be_activated
  end
end
