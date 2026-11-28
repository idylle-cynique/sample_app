# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ブラウザーでのプロフィール編集" do
  let(:user) { create(:user, activated: true) }

  before do
    driven_by :selenium, using: :headless_chrome
  end

  it "認証後に要求した編集画面へ戻り、名前を変更できる" do
    visit edit_user_path(user)
    expect(page).to have_current_path(login_path)
    fill_in "session_email", with: user.email
    fill_in "session_password", with: user.password
    click_button "Log in"

    expect(page).to have_current_path(edit_user_path(user))
    fill_in "user_name", with: "Renamed User"
    click_button "Save my changes"

    expect(page).to have_current_path(user_path(user))
    expect(page).to have_css(".user_info h1", text: "Renamed User")
    expect(user.reload.name).to eq("Renamed User")
  end
end
