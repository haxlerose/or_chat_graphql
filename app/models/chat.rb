# frozen_string_literal: true

class Chat < ApplicationRecord
  validates :llm_model, presence: true
end
