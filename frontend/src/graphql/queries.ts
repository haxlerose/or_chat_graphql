import { gql } from '@apollo/client';

export const GET_CHATS = gql`
  query GetChats {
    chats {
      id
      name
      llmModel
      messages(last: 1) {
        content
        role
        createdAt
      }
    }
  }
`;

export const GET_CHAT = gql`
  query GetChat($id: ID!) {
    chat(id: $id) {
      id
      name
      llmModel
      messages {
        id
        content
        role
        createdAt
      }
    }
  }
`;
