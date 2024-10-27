# frozen_string_literal: true

module Types
  class ChatType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :name, String, null: true
    field :llm_model, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
