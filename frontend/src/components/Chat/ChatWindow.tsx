import { useQuery } from '@apollo/client';
import { useParams } from 'react-router-dom';
import { GET_CHAT, GET_LLM_PRICING } from '@/graphql/queries';
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

type LlmPricing = {
  name: string;
  cost: number;
};

export const ChatWindow = () => {
  const { chatId } = useParams();
  const isNewChat = !chatId;

  const { data: chatData, loading: chatLoading, error: chatError } = useQuery(GET_CHAT, {
    variables: { id: chatId },
    skip: isNewChat,
  });

  const { data: pricingData, loading: pricingLoading } = useQuery(GET_LLM_PRICING);

  if (chatLoading || (isNewChat && pricingLoading)) {
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

  if (chatError && !isNewChat) {
    return (
      <div className="flex-1 h-screen flex flex-col p-4">
        <div className="text-red-500">Error loading chat: {chatError.message}</div>
      </div>
    );
  }

  const chat = chatData?.chat;
  const availableModels = pricingData?.llmPricing || [];

  return (
    <div className="flex-1 h-screen flex flex-col">
      <div className="p-4 border-b">
        <h2 className="text-lg font-bold">
          {isNewChat ? 'New Chat' : chat?.name}
        </h2>
        {!isNewChat && (
          <div className="text-sm text-gray-500">Using {chat?.llmModel}</div>
        )}
      </div>

      {!isNewChat ? (
        <div className="flex-1 overflow-auto p-4 space-y-4">
          {chat?.messages.map((message) => (
            <Message key={message.id} message={message} />
          ))}
        </div>
      ) : (
        <div className="flex-1 p-4 flex items-center justify-center">
          <div className="max-w-2xl w-full space-y-4">
            {availableModels.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Select Model
                </label>
                <select
                  defaultValue={availableModels[0].name}
                  className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:outline-none focus:border-blue-500"
                >
                  {availableModels.map((model: LlmPricing) => (
                    <option key={model.name} value={model.name}>
                      {model.name} (${model.cost} per million tokens)
                    </option>
                  ))}
                </select>
              </div>
            )}
            <MessageInput isNewChat />
          </div>
        </div>
      )}

      {!isNewChat && (
        <div className="border-t p-4">
          <MessageInput chatId={chatId} />
        </div>
      )}
    </div>
  );
};
