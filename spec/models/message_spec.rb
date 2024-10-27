# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:message)).to be_valid
    end

    it 'has a valid assistant factory' do
      expect(build(:message, :assistant)).to be_valid
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:role) }
    it { should belong_to(:chat) }
  end

  describe 'callbacks' do
    describe '#set_position' do
      it 'sets position to 1 for first message in a chat' do
        chat = create(:chat)
        expect(chat.messages.first.position).to eq(1)
      end

      it 'increments position for subsequent messages' do
        chat = create(:chat)  # Creates first message with position 1
        second_message = create(:message, :assistant, chat: chat)
        expect(second_message.position).to eq(2)
      end
    end

    describe '#destroy_following_messages' do
      it 'destroys messages with higher positions when a message is destroyed' do
        chat = create(:chat, :with_conversation)
        first_message = chat.messages.first

        expect {
          first_message.destroy
        }.to change(Message, :count).by(-2)  # Destroys both messages
      end

      it 'destroys messages with higher positions when a message is updated' do
        chat = create(:chat, :with_conversation)
        first_message = chat.messages.first

        expect {
          first_message.update(content: "Updated content")
        }.to change(Message, :count).by(-1)  # Destroys the second message
      end
    end
  end
end
