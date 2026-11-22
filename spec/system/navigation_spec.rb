# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Mobile navigation", type: :system do
  before do
    driven_by :selenium, using: :chrome
  end

  it "opens and closes the navigation menu from the hamburger button" do
    page.driver.browser.manage.window.resize_to(375, 812)
    visit root_path

    expect(page).not_to have_css("#navbar-menu", visible: true)

    click_button "hamburger"
    expect(page).to have_css("#navbar-menu", visible: true)

    click_button "hamburger"
    expect(page).not_to have_css("#navbar-menu", visible: true)
  end
end
