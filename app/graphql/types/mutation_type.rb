# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_message, mutation: Mutations::CreateMessage
    field :delete_chat, mutation: Mutations::DeleteChat
  end
end
