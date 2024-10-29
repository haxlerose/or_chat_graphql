import { useState } from 'react';
import { useMutation } from '@apollo/client';
import { GET_CHAT } from '@/graphql/queries';
import { CREATE_MESSAGE } from '@/graphql/mutations';

type MessageInputProps = {
  chatId: string;
};

export const MessageInput = ({ chatId }: MessageInputProps) => {
  const [content, setContent] = useState('');
  const [createMessage, { loading }] = useMutation(CREATE_MESSAGE, {
    refetchQueries: [
      { query: GET_CHAT, variables: { id: chatId } }
    ]
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim() || loading) return;

    try {
      await createMessage({
        variables: {
          chatId,
          content: content.trim()
        }
      });
      setContent('');
    } catch (error) {
      console.error('Failed to send message:', error);
      // You might want to show an error toast here
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <input
        type="text"
        value={content}
        onChange={(e) => setContent(e.target.value)}
        className="flex-1 rounded-lg border border-gray-300 px-4 py-2 focus:outline-none focus:border-blue-500"
        placeholder="Type a message..."
        disabled={loading}
      />
      <button
        type="submit"
        disabled={loading || !content.trim()}
        className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading ? 'Sending...' : 'Send'}
      </button>
    </form>
  );
};
