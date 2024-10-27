# frozen_string_literal: true

class LlmModel
  def self.all
    Rails.cache.fetch('all_open_router_llm_models', expires_in: 12.hours) do
      Rails.logger.info('Fetching all OpenRouter LLM models')
      OpenRouter::Client.new(access_token: Rails.application.credentials.open_router.access_token)
                        .models
                        .sort_by { |model| model['id'] }
    end
  end

  def self.pricing_per_million_tokens
    all.map do |model|
      { name: model['id'],
        cost: ((model['pricing']['prompt'].to_f + model['pricing']['completion'].to_f) * 1_000_000).round(2) }
    end
  end
end
