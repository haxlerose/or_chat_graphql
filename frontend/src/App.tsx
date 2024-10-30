import { Routes, Route } from 'react-router-dom'
import { ChatList } from './components/Chat/ChatList'
import { ChatWindow } from './components/Chat/ChatWindow'

function App() {
  return (
    <div className="flex h-screen">
      <ChatList />
      <Routes>
        <Route path="/" element={<div className="flex-1 grid place-items-center">Select or start a chat</div>} />
        <Route path="/new" element={<ChatWindow />} />
        <Route path="/chats/:chatId" element={<ChatWindow />} />
      </Routes>
    </div>
  )
}

export default App
