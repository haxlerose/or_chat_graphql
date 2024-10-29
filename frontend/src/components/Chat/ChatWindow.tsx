import { useQuery } from '@apollo/client';
import { useParams } from 'react-router-dom';
import { GET_CHAT } from '@/graphql/queries';
import { MessageInput } from './MessageInput';
import { Message } from './Message';

type Message = {
  id: string;
  content: string;
  role: string;
  createdAt: string;
};

type Chat = {
  id: string;
  name: string;
  llmModel: string;
  messages: Message[];
};

export const ChatWindow = () => {
  const { chatId } = useParams();
  const { data, loading, error } = useQuery(GET_CHAT, {
    variables: { id: chatId },
    skip: !chatId,
  });

  const chat = data?.node as Chat;

  if (!chatId) return null;

  if (loading) {
    return (
      <div className="flex-1 h-screen flex flex-col p-4">
        <div className="animate-pulse space-y-4">
          {[1, 2, 3].map((n) => (
            <div key={n} className="h-20 bg-gray-100 rounded"></div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex-1 h-screen flex flex-col p-4">
        <div className="text-red-500">Error loading chat</div>
      </div>
    );
  }

  return (
    <div className="flex-1 h-screen flex flex-col">
      <div className="p-4 border-b">
        <h2 className="text-lg font-bold">{chat?.name}</h2>
        <div className="text-sm text-gray-500">Using {chat?.llmModel}</div>
      </div>

      <div className="flex-1 overflow-auto p-4 space-y-4">
        {chat?.messages.map((message) => (
          <Message key={message.id} message={message} />
        ))}
      </div>

      <div className="border-t p-4">
        <MessageInput chatId={chatId} />
      </div>
    </div>
  );
};
