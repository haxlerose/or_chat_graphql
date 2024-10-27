# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
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
end
