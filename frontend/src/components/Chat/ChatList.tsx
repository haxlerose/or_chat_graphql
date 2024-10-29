import { useQuery } from '@apollo/client';
import { Link, useParams } from 'react-router-dom';
import { GET_CHATS } from '@/graphql/queries';

type Chat = {
  id: string;
  name: string;
  llmModel: string;
  messages: {
    content: string;
    role: string;
    createdAt: string;
  }[];
};

export const ChatList = () => {
  const { data, loading, error } = useQuery(GET_CHATS);
  const { chatId } = useParams();

  if (loading) {
    return (
      <div className="w-64 border-r h-screen p-4">
        <h2 className="text-lg font-bold mb-4">Chats</h2>
        <div className="animate-pulse">
          {[1, 2, 3].map((n) => (
            <div key={n} className="h-16 bg-gray-100 rounded mb-2"></div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="w-64 border-r h-screen p-4">
        <h2 className="text-lg font-bold mb-4">Chats</h2>
        <p className="text-red-500">Error loading chats</p>
      </div>
    );
  }

  return (
    <div className="w-64 border-r h-screen p-4">
      <h2 className="text-lg font-bold mb-4">Chats</h2>
      <div className="space-y-2">
        {data?.chats.map((chat: Chat) => (
          <Link
            key={chat.id}
            to={`/chats/${chat.id}`}
            className={`block p-3 rounded hover:bg-gray-100 transition-colors ${
              chatId === chat.id ? 'bg-gray-100' : ''
            }`}
          >
            <div className="font-medium truncate">{chat.name}</div>
            {chat.messages[0] && (
              <div className="text-sm text-gray-500 truncate">
                {chat.messages[0].content}
              </div>
            )}
            <div className="text-xs text-gray-400 mt-1">
              {chat.llmModel}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
};
