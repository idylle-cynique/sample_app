# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Static pages", type: :request do
  BASE_TITLE = "Ruby on Rails Tutorial Sample App"

  {
    "/" => ["Welcome to the Sample App", BASE_TITLE],
    "/help" => ["Help", "Help | #{BASE_TITLE}"],
    "/about" => ["About", "About | #{BASE_TITLE}"],
    "/contact" => ["Contact", "Contact | #{BASE_TITLE}"]
  }.each do |path, (heading, title)|
    it "renders #{path} with its heading and page title" do
      get path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<h1>#{heading}</h1>")
      expect(response.body).to include("<title>#{title}</title>")
    end
  end

  it "renders the guest header and footer links with their expected paths" do
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
