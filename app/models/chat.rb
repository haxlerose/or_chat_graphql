# frozen_string_literal: true

class Chat < ApplicationRecord
  has_many :messages, dependent: :destroy

  validates :llm_model, presence: true
  validates :llm_model, inclusion: { in: LlmModel.all.map { |model| model['id'] } }
  validates :messages, presence: true, on: :create
end
