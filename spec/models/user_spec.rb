# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a name, email, and matching password" do
    expect(build(:user)).to be_valid
  end

  it "requires a name" do
    user = build(:user, name: "")

    expect(user).to be_invalid
    expect(user.errors.details[:name].first[:error]).to eq(:blank)
  end

  it "allows names up to 50 characters" do
    user = build(:user, name: "a" * 50)

    expect(user).to be_valid
  end

  it "rejects names longer than 50 characters" do
    user = build(:user, name: "a" * 51)

    expect(user).to be_invalid
    expect(user.errors.details[:name].first[:error]).to eq(:too_long)
  end

  it "requires an email address" do
    user = build(:user, email: "")

    expect(user).to be_invalid
    expect(user.errors.details[:email].first[:error]).to eq(:blank)
  end

  it "allows email addresses up to 255 characters" do
    email = "a" * 243 + "@example.com"
    user = build(:user, email: email)

    expect(user).to be_valid
  end

  it "rejects email addresses longer than 255 characters" do
    email = "a" * 244 + "@example.com"
    user = build(:user, email: email)

    expect(user).to be_invalid
    expect(user.errors.details[:email].first[:error]).to eq(:too_long)
  end

  it "accepts valid email formats and rejects invalid formats" do
    expect(build(:user, email: "user@example.com")).to be_valid

    ["user", "user@", "user name@example.com"].each do |email|
      expect(build(:user, email: email)).to be_invalid
    end
  end

  it "treats email uniqueness as case insensitive" do
    create(:user, email: "User@example.com")
    duplicate = build(:user, email: "user@example.com")

    expect(duplicate).to be_invalid
    expect(duplicate.errors.details[:email].first[:error]).to eq(:taken)
  end

  it "normalizes the saved email address to lowercase" do
    user = create(:user, email: "User@Example.COM")

    expect(user.reload.email).to eq("user@example.com")
  end

  it "requires a password" do
    user = build(:user, password: "", password_confirmation: "")

    expect(user).to be_invalid
    expect(user.errors.details[:password].first[:error]).to eq(:blank)
  end

  it "requires passwords to be at least six characters long" do
    short_password = build(:user, password: "12345", password_confirmation: "12345")
    six_character_password = build(:user, password: "123456", password_confirmation: "123456")

    expect(short_password).to be_invalid
    expect(six_character_password).to be_valid
  end

  it "rejects a password containing only whitespace" do
    user = build(:user, password: " " * 6, password_confirmation: " " * 6)

    expect(user).to be_invalid
  end

  it "requires the password confirmation to match" do
    user = build(:user, password_confirmation: "different")

    expect(user).to be_invalid
    expect(user.errors.details[:password_confirmation].first[:error]).to eq(:confirmation)
  end
end
