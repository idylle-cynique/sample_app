# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  it "returns the base title when the page title is empty" do
    expect(helper.full_title("")).to eq(base_title)
  end

  it "combines the page title and base title" do
    expect(helper.full_title("Help")).to eq("Help | #{base_title}")
  end
end
