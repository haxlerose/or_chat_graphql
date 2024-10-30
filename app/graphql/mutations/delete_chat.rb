# frozen_string_literal: true

module Mutations
  class DeleteChat < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      chat = Chat.find(id)

      if chat.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: chat.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound
      { success: false, errors: ['Chat not found'] }
    end
  end
end
