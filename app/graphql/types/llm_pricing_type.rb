# frozen_string_literal: true

module Types
  class LlmPricingType < Types::BaseObject
    field :name, String, null: false, description: 'The ID/name of the LLM model'
    field :cost, Float, null: false, description: 'Cost per million tokens in USD'
  end
end
