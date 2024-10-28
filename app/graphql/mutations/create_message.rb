# frozen_string_literal: true

module Mutations
  class CreateMessage < BaseMutation
    argument :content, String, required: true
    argument :chat_id, ID, required: false
    argument :llm_model, String, required: false
    argument :name, String, required: false

    field :chat, Types::ChatType, null: true
    field :user_message, Types::MessageType, null: true
    field :assistant_message, Types::MessageType, null: true
    field :errors, [String], null: false

    def resolve(content:, chat_id: nil, llm_model: nil, name: nil)
      # Validate we have either chat_id or llm_model
      if chat_id.nil? && llm_model.nil?
        return {
          chat: nil,
          user_message: nil,
          assistant_message: nil,
          errors: ['Must provide either chat_id for existing chat or llm_model for new chat']
        }
      end

      Chat.transaction do
        # Get or create chat
        chat = if chat_id
                 Chat.find(chat_id)
               else
                 # For new chats, use provided name or generate a default
                 chat_name = name.presence || "Chat #{Time.current.strftime('%Y-%m-%d %H:%M')}"
                 Chat.create!(
                   llm_model: llm_model,
                   name: chat_name
                 )
               end

        # Create user message - now with role
        user_message = chat.messages.create!(
          content: content,
          role: :user # This was missing before!
        )

        # Get response from LLM
        response = LlmResponse.new(chat).complete
        if response['error']
          Rails.logger.error("Open Router API error: #{response['error']}")
          assistant_message = nil
        else
          response_content = response.dig('choices', 0, 'message', 'content')
          if response_content.blank?
            Rails.logger.error("No response content:\n#{response}")
            raise 'No response content'
          else
            assistant_message = chat.messages.create!(role: 'assistant', content: response_content)
          end
        end

        if assistant_message
          {
            chat: chat,
            user_message: user_message,
            assistant_message: assistant_message,
            errors: []
          }
        else
          {
            chat: chat,
            user_message: user_message,
            assistant_message: nil,
            errors: assistant_message.errors.full_messages
          }
        end
      end
    rescue ActiveRecord::RecordNotFound
      {
        chat: nil,
        user_message: nil,
        assistant_message: nil,
        errors: ['Chat not found']
      }
    rescue ActiveRecord::RecordInvalid => e
      {
        chat: nil,
        user_message: nil,
        assistant_message: nil,
        errors: [e.record.errors.full_messages.join(', ')]
      }
    rescue StandardError => e
      {
        chat: nil,
        user_message: nil,
        assistant_message: nil,
        errors: [e.message]
      }
    end
  end
end
