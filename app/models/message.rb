# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :chat, touch: true

  validates :content, presence: true
  validates :role, presence: true

  enum :role, %i[assistant user]

  before_create :set_position
  after_commit :destroy_following_messages, on: %i[destroy update]

  private

  def set_position
    self.position = (chat.messages.maximum(:position) || 0) + 1
  end

  def destroy_following_messages
    return unless saved_change_to_attribute?(:content) || destroyed?

    chat.messages.where('position > ?', position).destroy_all
  end
end
