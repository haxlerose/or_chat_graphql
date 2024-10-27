# frozen_string_literal: true

module Mutations
  class CreateChat < BaseMutation
    # Arguments that can be passed to this mutation
    argument :name, String, required: false
    argument :llm_model, String, required: true

    # Fields that will be returned by this mutation
    field :chat, Types::ChatType, null: true
    field :errors, [String], null: false

    def resolve(llm_model:, name: nil)
      chat = Chat.new(name: name, llm_model: llm_model)

      if chat.save
        {
          chat: chat,
          errors: []
        }
      else
        {
          chat: nil,
          errors: chat.errors.full_messages
        }
      end
    end
  end
end
