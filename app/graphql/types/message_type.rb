# frozen_string_literal: true

module Types
  class MessageType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    field :id, ID, null: false
    field :content, String, null: false
    field :role, String, null: false
    field :position, Integer, null: false
    field :chat_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
