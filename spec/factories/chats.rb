# frozen_string_literal: true

FactoryBot.define do
  factory :chat do
    sequence(:name) { |n| "Chat #{n}" }
    llm_model { 'anthropic/claude-2' }

    after(:build) do |chat|
      chat.messages << build(:message, chat: chat) unless chat.messages.any?
    end

    trait :with_conversation do
      after(:create) do |chat, evaluator|
        # The first message is already created by the after(:build) callback
        # Now create the assistant message
        create(:message, :assistant, chat: chat)
        chat.reload  # Make sure we have the latest messages
      end
    end
  end
end
