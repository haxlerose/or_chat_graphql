# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    sequence(:name) { |n| "Chat #{n}" }
    llm_model { "gpt-4" }
  end
end
