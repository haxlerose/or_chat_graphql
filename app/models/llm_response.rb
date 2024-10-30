# frozen_string_literal: true

class LlmResponse
  def initialize(chat)
    @chat = chat
    uri = URI('https://openrouter.ai/api/v1/chat/completions')
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    @request = Net::HTTP::Post.new(
      uri.path,
      { 'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{Rails.application.credentials.open_router.access_token}" }
    )
  end

  def complete
    @request.body = {
      model: @chat.llm_model,
      messages: @chat.history,
      stream: false
    }.to_json

    response = @http.request(@request)
    parsed = JSON.parse(response.body)
    parsed
  end
end
