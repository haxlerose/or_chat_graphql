# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LlmModel do
  let(:mock_models) do
    [
      {
        'id' => 'anthropic/claude-2',
        'pricing' => {
          'prompt' => '0.00008',
          'completion' => '0.00024'
        }
      }
    ]
  end

  let(:mock_client) { instance_double(OpenRouter::Client, models: mock_models) }

  before(:all) do
    @original_cache_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  after(:all) do
    Rails.cache = @original_cache_store
  end

  before(:each) do
    Rails.cache.clear
    allow(OpenRouter::Client).to receive(:new)
      .with(access_token: Rails.application.credentials.open_router.access_token)
      .and_return(mock_client)
    allow(Rails.logger).to receive(:info)
  end

  describe '.all' do
    it 'fetches and caches models from OpenRouter' do
      result = described_class.all
      expect(result).to eq(mock_models)
      expect(Rails.logger).to have_received(:info).with('Fetching all OpenRouter LLM models').once

      second_result = described_class.all
      expect(second_result).to eq(mock_models)
      expect(Rails.logger).to have_received(:info).with('Fetching all OpenRouter LLM models').once
    end

    context 'when cache expires' do
      it 'fetches fresh data' do
        described_class.all
        expect(Rails.logger).to have_received(:info).once

        travel 13.hours
        Rails.cache.clear

        described_class.all
        expect(Rails.logger).to have_received(:info).twice
      end
    end
  end

  describe '.pricing_per_million_tokens' do
    it 'calculates correct pricing for each model' do
      expect(described_class.pricing_per_million_tokens).to eq([
        {
          name: 'anthropic/claude-2',
          cost: 320.0
        }
      ])
    end
  end
end
