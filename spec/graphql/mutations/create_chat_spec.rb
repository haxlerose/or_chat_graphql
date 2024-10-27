# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateChat, type: :request do
  let(:mutation) do
    <<~GQL
      mutation($name: String, $llmModel: String!, $content: String!) {
        createChat(input: { name: $name, llmModel: $llmModel, content: $content }) {
          chat {
            id
            name
            llmModel
            messages {
              id
              content
              role
              position
            }
          }
          message {
            id
            content
            role
            position
          }
          errors
        }
      }
    GQL
  end

  def execute_mutation(variables = {})
    post '/graphql', params: {
      query: mutation,
      variables: variables
    }
    json = JSON.parse(response.body)
    puts "Debug response: #{json.inspect}" if json["errors"]  # Add this line for debugging
    json
  end

  before do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  describe "creating a new chat" do
    context "with valid attributes" do
      it "creates a new chat with initial message" do
        expect {
          result = execute_mutation(
            name: "My Chat",
            llmModel: "anthropic/claude-2",
            content: "Hello, AI!"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["errors"]).to be_empty

          # Check chat
          expect(mutation_result["chat"]["name"]).to eq("My Chat")
          expect(mutation_result["chat"]["llmModel"]).to eq("anthropic/claude-2")

          # Check message
          expect(mutation_result["message"]["content"]).to eq("Hello, AI!")
          expect(mutation_result["message"]["role"]).to eq("user")
          expect(mutation_result["message"]["position"]).to eq(1)

          # Check chat's messages
          expect(mutation_result["chat"]["messages"].length).to eq(1)
          expect(mutation_result["chat"]["messages"].first["content"]).to eq("Hello, AI!")
        }.to change(Chat, :count).by(1)
         .and change(Message, :count).by(1)
      end

      it "creates a chat without a name" do
        expect {
          result = execute_mutation(
            llmModel: "anthropic/claude-2",
            content: "Hello!"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["errors"]).to be_empty
          expect(mutation_result["chat"]["name"]).to be_nil
          expect(mutation_result["message"]).to be_present
        }.to change(Chat, :count).by(1)
         .and change(Message, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "returns errors for invalid model" do
        expect {
          result = execute_mutation(
            name: "My Chat",
            llmModel: "invalid-model",
            content: "Hello!"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["chat"]).to be_nil
          expect(mutation_result["message"]).to be_nil
          expect(mutation_result["errors"]).to include("Llm model is not included in the list")
        }.to change(Chat, :count).by(0)
         .and change(Message, :count).by(0)
      end

      it "returns errors when content is missing" do
        expect {
          result = execute_mutation(
            name: "My Chat",
            llmModel: "anthropic/claude-2",
            content: ""
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["chat"]).to be_nil
          expect(mutation_result["message"]).to be_nil
          expect(mutation_result["errors"]).to include("Content can't be blank")
        }.not_to change(Chat, :count)
      end
    end
  end
end
