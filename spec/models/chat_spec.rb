# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chat, type: :model do
  before do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:chat)).to be_valid
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:llm_model) }

    context 'when llm_model is nil' do
      it 'is invalid' do
        chat = build(:chat, llm_model: nil)
        expect(chat).not_to be_valid
        expect(chat.errors[:llm_model]).to include("can't be blank")
      end
    end

    context 'when llm_model is an empty string' do
      it 'is invalid' do
        chat = build(:chat, llm_model: '')
        expect(chat).not_to be_valid
        expect(chat.errors[:llm_model]).to include("can't be blank")
      end
    end
  end
end
