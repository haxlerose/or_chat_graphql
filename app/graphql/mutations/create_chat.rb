# frozen_string_literal: true

# app/graphql/mutations/create_chat.rb
module Mutations
  class CreateChat < BaseMutation
    argument :name, String, required: false
    argument :llm_model, String, required: true
    argument :content, String, required: true

    field :chat, Types::ChatType, null: true
    field :message, Types::MessageType, null: true
    field :errors, [String], null: false

    def resolve(llm_model:, content:, name: nil)
      Chat.transaction do
        chat = Chat.new(name: name, llm_model: llm_model)
        message = chat.messages.build(
          content: content,
          role: 'user'
        )

        if chat.save
          {
            chat: chat,
            message: message,
            errors: []
          }
        else
          {
            chat: nil,
            message: nil,
            errors: chat.errors.full_messages + message.errors.full_messages
          }
        end
      end
    end
  end
end
