# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat, type: :model do
  before do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  describe 'factory' do
    it 'creates chat with initial message' do
      chat = create(:chat)
      expect(chat.messages.count).to eq(1)
      expect(chat.messages.first.role).to eq("user")  # The test will pass with either "user" or :user
    end

    it 'can create chat with conversation' do
      chat = create(:chat, :with_conversation)
      expect(chat.messages.count).to eq(2)
      expect(chat.messages.first.role).to eq("user")
      expect(chat.messages.last.role).to eq("assistant") # The test will pass with either "assistant" or :assistant
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:llm_model) }

    it 'requires at least one message on create' do
      chat = build(:chat)
      chat.messages = []
      expect(chat).not_to be_valid
      expect(chat.errors[:messages]).to include("can't be blank")
    end

    context 'when llm_model is invalid' do
      it 'is invalid' do
        chat = build(:chat, llm_model: 'invalid-model')
        expect(chat).not_to be_valid
        expect(chat.errors[:llm_model]).to include('is not included in the list')
      end
    end
  end

  describe 'associations' do
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe '#history' do
    it 'returns empty array when no messages exist' do
      chat = create(:chat)
      chat.messages.destroy_all
      expect(chat.history).to eq([])
    end

    it 'returns messages in position order' do
      chat = create(:chat, :with_conversation)

      expect(chat.history).to eq([
        { role: 'user', content: chat.messages.first.content },
        { role: 'assistant', content: chat.messages.last.content }
      ])
    end

    it 'maintains correct order with multiple messages' do
      chat = create(:chat)
      message2 = create(:message, :assistant, chat: chat)
      message3 = create(:message, chat: chat)

      expect(chat.history).to eq([
        { role: 'user', content: chat.messages.first.content },
        { role: 'assistant', content: message2.content },
        { role: 'user', content: message3.content }
      ])
    end

    it 'formats messages correctly regardless of role' do
      chat = create(:chat)
      second_message = create(:message, :assistant, chat: chat, content: "I'm here to help!")

      expected_history = [
        { role: 'user', content: chat.messages.first.content },
        { role: 'assistant', content: "I'm here to help!" }
      ]

      expect(chat.history).to eq(expected_history)
    end

    context 'when messages are deleted' do
      it 'maintains correct order for remaining messages' do
        chat = create(:chat, :with_conversation)
        first_message = chat.messages.find_by(position: 1)
        second_message = chat.messages.find_by(position: 2)

        # Verify initial state
        expect(chat.history).to eq([
          { role: 'user', content: first_message.content },
          { role: 'assistant', content: second_message.content }
        ])

        # Delete first message (this should trigger the callback that deletes later messages)
        first_message.destroy

        # Now we should only have the new message we create
        new_message = create(:message, chat: chat, content: "A fresh start")

        # Should only have the new message with position 1
        expect(chat.history).to eq([
          { role: 'user', content: "A fresh start" }
        ])
      end

      it 'resets positions when intermediate messages are deleted' do
        chat = create(:chat)  # Creates first message with position 1
        chat.reload  # Make sure we have fresh data

        # Create subsequent messages and verify positions after each create
        message2 = create(:message, :assistant, chat: chat, content: "I'm here to help!")
        chat.reload
        message3 = create(:message, chat: chat, content: "Thank you")
        chat.reload

        # Initial state check
        expect(chat.messages.order(:position).pluck(:position)).to eq([1, 2, 3])

        # Delete middle message
        message2.destroy

        # All messages after the deleted one should also be deleted
        expect(chat.messages.count).to eq(1)
        expect(chat.history).to eq([
          { role: 'user', content: chat.messages.first.content }
        ])
      end
    end
  end
end
