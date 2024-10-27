# frozen_string_literal: true

class Chat < ApplicationRecord
  validates :llm_model, presence: true
  validates :llm_model, inclusion: { in: LlmModel.all.map { |model| model['id'] } }
end
