# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  before(:each) do
    allow(LlmModel).to receive(:all).and_return([{ 'id' => 'anthropic/claude-2' }])
  end

  let(:context) { {} }
  let(:variables) { {} }

  let(:chats_query) do
    <<~GQL
      query {
        chats {
          id
          name
          llmModel
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:node_query) do
    <<~GQL
      query($id: ID!) {
        node(id: $id) {
          id
          ... on Chat {
            name
            llmModel
            createdAt
            updatedAt
          }
        }
      }
    GQL
  end

  def execute_query(query: chats_query, context: {}, variables: {})
    OrChatGraphqlSchema.execute(
      query,
      context: context,
      variables: variables
    )
  end

  describe "chats query" do
    let!(:chat) { create(:chat) }

    it "returns all chats" do
      result = execute_query

      chats_result = result["data"]["chats"]
      expect(chats_result).to be_an(Array)
      expect(chats_result.length).to eq(1)

      chat_result = chats_result.first
      expect(chat_result["name"]).to eq(chat.name)
      expect(chat_result["llmModel"]).to eq(chat.llm_model)
    end

    it "returns empty array when no chats exist" do
      Chat.destroy_all
      result = execute_query

      expect(result["data"]["chats"]).to eq([])
    end
  end

  describe "node query" do
    let!(:chat) { create(:chat) }

    it "returns a single chat by global ID" do
      result = execute_query(
        query: node_query,
        variables: { id: chat.to_gid_param }
      )

      node_result = result["data"]["node"]
      expect(node_result["name"]).to eq(chat.name)
      expect(node_result["llmModel"]).to eq(chat.llm_model)
    end

    it "returns null for non-existent ID" do
      result = execute_query(
        query: node_query,
        variables: { id: "Z2lkOi8vb3ItY2hhdC1ncmFwaHFsL0NoYXQvOTk5OTk=" }
      )

      expect(result["data"]["node"]).to be_nil
    end

    it "returns null for invalid ID format" do
      result = execute_query(
        query: node_query,
        variables: { id: "invalid-id" }
      )

      expect(result["data"]["node"]).to be_nil
    end
  end

  describe "llm_pricing query" do
    let(:query) do
      <<~GQL
        query {
          llmPricing {
            name
            cost
          }
        }
      GQL
    end

    let(:mock_pricing) do
      [
        {
          name: 'anthropic/claude-2',
          cost: 320.0
        }
      ]
    end

    before do
      allow(LlmModel).to receive(:pricing_per_million_tokens).and_return(mock_pricing)
    end

    it "returns pricing for all models" do
      result = execute_query(query: query)

      expect(result["data"]["llmPricing"]).to eq(
        mock_pricing.map { |p| { "name" => p[:name], "cost" => p[:cost] } }
      )
    end

    it "returns empty array when no models available" do
      allow(LlmModel).to receive(:pricing_per_million_tokens).and_return([])
      result = execute_query(query: query)

      expect(result["data"]["llmPricing"]).to eq([])
    end
  end
end
