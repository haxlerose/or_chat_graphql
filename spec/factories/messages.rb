# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { "Hello, AI!" }
    role { :user }
    chat

    trait :assistant do
      content { "Hello! How can I help you today?" }
      role { :assistant }
    end
  end
end
