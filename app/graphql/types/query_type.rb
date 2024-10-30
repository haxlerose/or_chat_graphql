# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :node, Types::NodeType, null: true, description: 'Fetches an object given its ID.' do
      argument :id, ID, required: true, description: 'ID of the object.'
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, { null: true }], null: true,
                                                     description: 'Fetches a list of objects given a list of IDs.' do
      argument :ids, [ID], required: true, description: 'IDs of the objects.'
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :chats, [Types::ChatType], null: false, description: 'Fetch all chats'
    def chats
      Chat.order(updated_at: :desc)
    end

    field :chat, Types::ChatType, null: true do
      argument :id, ID, required: true
      description 'Find a chat by ID'
    end

    def chat(id:)
      Chat.find(id)
    end

    field :llm_pricing, [Types::LlmPricingType], null: false,
                                                 description: 'Get pricing for all available LLM models'
    def llm_pricing
      LlmModel.pricing_per_million_tokens
    end
  end
end
