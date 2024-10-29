# frozen_string_literal: true

module Types
  class ChatType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :llm_model, String, null: false
    field :messages, [Types::MessageType], null: false do
      argument :last, Integer, required: false
    end
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def messages(last: nil)
      messages = object.messages.order(created_at: :asc)
      last ? messages.last(last) : messages
    end
  end
end
