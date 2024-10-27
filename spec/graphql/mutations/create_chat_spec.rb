# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateChat, type: :request do
  let(:mutation) do
    <<~GQL
      mutation($name: String, $llmModel: String!) {
        createChat(input: { name: $name, llmModel: $llmModel }) {
          chat {
            id
            name
            llmModel
          }
          errors
        }
      }
    GQL
  end

  before do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  def execute_mutation(variables = {})
    post '/graphql', params: {
      query: mutation,
      variables: variables
    }
    JSON.parse(response.body)
  end

  describe "creating a new chat" do
    context "with valid attributes" do
      it "creates a new chat" do
        expect {
          result = execute_mutation(
            name: "My Chat",
            llmModel: "anthropic/claude-2"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["errors"]).to be_empty
          expect(mutation_result["chat"]["name"]).to eq("My Chat")
          expect(mutation_result["chat"]["llmModel"]).to eq("anthropic/claude-2")
        }.to change(Chat, :count).by(1)
      end

      it "creates a chat without a name" do
        expect {
          result = execute_mutation(
            llmModel: "anthropic/claude-2"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["errors"]).to be_empty
          expect(mutation_result["chat"]["name"]).to be_nil
          expect(mutation_result["chat"]["llmModel"]).to eq("anthropic/claude-2")
        }.to change(Chat, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "returns errors for invalid model" do
        expect {
          result = execute_mutation(
            name: "My Chat",
            llmModel: "invalid-model"
          )

          mutation_result = result.dig("data", "createChat")
          expect(mutation_result["chat"]).to be_nil
          expect(mutation_result["errors"]).to include("Llm model is not included in the list")
        }.not_to change(Chat, :count)
      end

      it "returns errors when model is missing" do
        expect {
          result = execute_mutation(
            name: "My Chat"
          )

          # For missing required arguments, GraphQL returns top-level errors
          expect(result["errors"]).to be_present
          expect(result["errors"].first["message"]).to include("llmModel")
          expect(result["data"]).to be_nil
        }.not_to change(Chat, :count)
      end
    end
  end
end
