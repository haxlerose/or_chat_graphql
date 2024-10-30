import { useQuery, useMutation } from '@apollo/client';
import { Link, useParams, useLocation, useNavigate } from 'react-router-dom';
import { GET_CHATS } from '@/graphql/queries';
import { DELETE_CHAT } from '@/graphql/mutations';
import { Trash2 } from 'lucide-react';

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
  const navigate = useNavigate();
  const { data, loading, error } = useQuery(GET_CHATS);
  const { chatId } = useParams();
  const location = useLocation();
  const isNewChat = location.pathname === '/new';

  const [deleteChat] = useMutation(DELETE_CHAT, {
    refetchQueries: [{ query: GET_CHATS }],
    onCompleted: (data) => {
      if (data.deleteChat.success && chatId === deletedChatId) {
        navigate('/');
      }
    }
  });

  let deletedChatId: string | null = null;

  const handleDeleteChat = async (
    e: React.MouseEvent,
    id: string
  ) => {
    e.preventDefault();
    deletedChatId = id;
    try {
      await deleteChat({
        variables: { id }
      });
    } catch (error) {
      console.error('Failed to delete chat:', error);
    }
  };

  return (
    <div className="w-64 border-r h-screen p-4 flex flex-col">
      <div className="mb-4">
        <Link
          to="/new"
          className={`w-full bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 flex items-center justify-center ${
            isNewChat ? 'bg-blue-600' : ''
          }`}
        >
          <span className="mr-2">+</span> New Chat
        </Link>
      </div>

      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="animate-pulse space-y-2">
            {[1, 2, 3].map((n) => (
              <div key={n} className="h-16 bg-gray-100 rounded"></div>
            ))}
          </div>
        ) : error ? (
          <p className="text-red-500">Error loading chats</p>
        ) : (
          <div className="space-y-2">
            {data?.chats.map((chat: Chat) => (
              <div
                key={chat.id}
                className="group relative"
              >
                <Link
                  to={`/chats/${chat.id}`}
                  className={`block p-3 rounded hover:bg-gray-100 transition-colors ${
                    chatId === chat.id ? 'bg-gray-100' : ''
                  }`}
                >
                  <div className="font-medium truncate pr-8">{chat.name}</div>
                  {chat.messages[0] && (
                    <div className="text-sm text-gray-500 truncate">
                      {chat.messages[0].content}
                    </div>
                  )}
                  <div className="text-xs text-gray-400 mt-1">
                    {chat.llmModel}
                  </div>
                </Link>
                <button
                  onClick={(e) => handleDeleteChat(e, chat.id)}
                  className="absolute right-2 top-3 opacity-0 group-hover:opacity-100 transition-opacity p-1 hover:bg-gray-200 rounded"
                  title="Delete chat"
                >
                  <Trash2 className="w-4 h-4 text-gray-500 hover:text-red-500" />
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};
