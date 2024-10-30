import { gql } from '@apollo/client';

export const CREATE_MESSAGE = gql`
  mutation CreateMessage($chatId: ID!, $content: String!) {
    createMessage(input: { chatId: $chatId, content: $content }) {
      chat {
        id
      }
      userMessage {
        id
        content
        role
        createdAt
      }
      assistantMessage {
        id
        content
        role
        createdAt
      }
      errors
    }
  }
`;

export const DELETE_CHAT = gql`
  mutation DeleteChat($id: ID!) {
    deleteChat(input: { id: $id }) {
      success
      errors
    }
  }
`;
