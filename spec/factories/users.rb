# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "Example User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "secret" }
    password_confirmation { password }
  end
end
