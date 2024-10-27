# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    sequence(:name) { |n| "Chat #{n}" }
    llm_model { 'anthropic/claude-2' }  # Just set a static value
  end
end
