import { useState } from 'react';
import { useMutation } from '@apollo/client';
import { useNavigate } from 'react-router-dom';
import { GET_CHAT } from '@/graphql/queries';
import { CREATE_MESSAGE } from '@/graphql/mutations';

type MessageInputProps = {
  chatId?: string;
  isNewChat?: boolean;
};

export const MessageInput = ({ chatId, isNewChat }: MessageInputProps) => {
  const navigate = useNavigate();
  const [content, setContent] = useState('');
  const [createMessage, { loading }] = useMutation(CREATE_MESSAGE, {
    onCompleted: (data) => {
      if (isNewChat && data.createMessage.chat?.id) {
        navigate(`/chats/${data.createMessage.chat.id}`);
      }
    },
    refetchQueries: chatId ? [
      { query: GET_CHAT, variables: { id: chatId } }
    ] : []
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim() || loading) return;

    try {
      const variables: any = {
        content: content.trim()
      };

      if (isNewChat) {
        const select = document.querySelector('select') as HTMLSelectElement;
        variables.llmModel = select.value;
      } else {
        variables.chatId = chatId;
      }

      await createMessage({ variables });
      setContent('');
    } catch (error) {
      console.error('Failed to send message:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <input
        type="text"
        value={content}
        onChange={(e) => setContent(e.target.value)}
        className="flex-1 rounded-lg border border-gray-300 px-4 py-2 focus:outline-none focus:border-blue-500"
        placeholder={isNewChat ? "Type your first message..." : "Type a message..."}
        disabled={loading}
      />
      <button
        type="submit"
        disabled={loading || !content.trim()}
        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading ? 'Sending...' : isNewChat ? 'Start Chat' : 'Send'}
      </button>
    </form>
  );
};
