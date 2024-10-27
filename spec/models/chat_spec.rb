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
end
