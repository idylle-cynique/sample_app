# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "requires a name" do
    user = User.new(
      name: nil,
      email: "user@example.com",
      password: "secret",
      password_confirmation: "secret"
    )

    expect(user).to be_invalid
    expect(user.errors.details[:name].first[:error]).to eq(:blank)
  end
end
