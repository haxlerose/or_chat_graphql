# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { "Hello, AI!" }
    role { :user }  # Use symbol to match enum definition
    chat

    trait :assistant do
      content { "Hello! How can I help you today?" }
      role { :assistant }  # Use symbol for assistant role
    end
  end
end
