# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ブラウザーでのログインとログアウト" do
  let(:user) { create(:user, activated: true) }

  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "誤ったパスワードで失敗した後に本人のプロフィールへログインできる" do
    submit_login(password: "wrong password")

    expect(page).to have_css(".alert-danger", text: "Invalid email/password combination")
    expect(page).to have_field("session_email", with: user.email)

    fill_in "session_password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_css("#account")
  end

  it "永続 Cookie で別のブラウザーに復元でき、ログアウト後は復元できない" do
    submit_login(remember_me: true)
    expect(page).to have_current_path(user_path(user))

    cookie_manager = page.driver.browser.manage
    remembered_cookies = %w[user_id remember_token].map { |name| cookie_manager.cookie_named(name) }
    session_key = Rails.application.config.session_options.fetch(:key)
    Capybara.using_session(:secondary_browser) do
      visit root_path
      page.driver.browser.manage.delete_cookie(session_key)
      remembered_cookies.each do |cookie|
        page.driver.browser.manage.add_cookie(cookie.slice(:name, :value, :expires))
      end

      visit edit_user_path(user)
      expect(page).to have_current_path(edit_user_path(user))
      expect(page).to have_button("Save my changes")

      find("#account").click
      click_link "Log out"
      expect(page).to have_link("Log in", href: login_path)
    end

    visit edit_user_path(user)
    expect(page).to have_current_path(login_path)

    cookie_manager.delete_cookie(session_key)
    visit edit_user_path(user)
    expect(page).to have_current_path(login_path)
  end

  it "Remember me をオフにするとセッション Cookie の消去後はゲストになる" do
    submit_login
    expect(page).to have_current_path(user_path(user))

    expect(page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }).not_to include(
      "user_id", "remember_token"
    )
    Capybara.using_session(:secondary_browser) do
      visit edit_user_path(user)
      expect(page).to have_current_path(login_path)
    end

    page.driver.browser.manage.delete_cookie(Rails.application.config.session_options.fetch(:key))
    visit edit_user_path(user)

    expect(page).to have_current_path(login_path)
  end

  private

  # ブラウザーで認証情報と記憶設定を入力してログインフォームを送信する。
  def submit_login(password: user.password, remember_me: false)
    visit login_path
    fill_in "session_email", with: user.email
    fill_in "session_password", with: password
    find(:checkbox, "session_remember_me").set(remember_me)
    click_button "Log in"
  end
end
