"use client";
import { useEffect, useRef } from "react";
import { useChatContext } from "@/context/ChatContext";
import { ChatMessageBubble } from "@/components/chat/ChatMessageBubble";
import { ChatInput } from "@/components/chat/ChatInput";

const SUGGESTIONS = [
  "How is my portfolio doing?",
  "Which stocks are underperforming?",
  "Suggest diversification strategies",
  "What are the risks in my portfolio?",
];

export default function ChatPage() {
  const { messages, sendMessage, isGenerating, clearChat } = useChatContext();
  const bottomRef = useRef<HTMLDivElement>(null);

  // Auto-scroll on new messages
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  return (
    <div className="flex flex-col h-[calc(100vh-57px)]">
      {/* Top bar */}
      <div className="border-b dark:border-slate-800 border-slate-200 px-6 py-3 flex items-center justify-between transition-colors">
        <div className="flex items-center gap-2">
          <div
            className="w-7 h-7 rounded-lg flex items-center justify-center"
            style={{
              background: "linear-gradient(135deg, #667EEA 0%, #764BA2 100%)",
            }}
          >
            <svg
              className="w-4 h-4 text-white"
              fill="currentColor"
              viewBox="0 0 24 24"
            >
              <path d="M19 9l1.25-2.75L23 5l-2.75-1.25L19 1l-1.25 2.75L15 5l2.75 1.25L19 9zm-7.5.5L9 4 6.5 9.5 1 12l5.5 2.5L9 20l2.5-5.5L17 12l-5.5-2.5zM19 15l-1.25 2.75L15 19l2.75 1.25L19 23l1.25-2.75L23 19l-2.75-1.25L19 15z" />
            </svg>
          </div>
          <h1 className="text-lg font-semibold">AI Chat</h1>
        </div>
        {messages.length > 0 && (
          <button
            onClick={clearChat}
            className="text-xs dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 transition-colors"
          >
            Clear chat
          </button>
        )}
      </div>

      {/* Messages area */}
      <div className="flex-1 overflow-y-auto px-6 py-4">
        {messages.length === 0 ? (
          <EmptyState onSuggestionClick={sendMessage} />
        ) : (
          <>
            {messages.map((msg) => (
              <ChatMessageBubble key={msg.id} message={msg} />
            ))}
            <div ref={bottomRef} />
          </>
        )}
      </div>

      {/* Input */}
      <ChatInput onSubmit={sendMessage} disabled={isGenerating} />
    </div>
  );
}

function EmptyState({
  onSuggestionClick,
}: {
  onSuggestionClick: (text: string) => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center h-full text-center px-4">
      <div
        className="w-16 h-16 rounded-2xl flex items-center justify-center mb-5"
        style={{
          background: "linear-gradient(135deg, #667EEA 0%, #764BA2 100%)",
        }}
      >
        <svg
          className="w-8 h-8 text-white"
          fill="currentColor"
          viewBox="0 0 24 24"
        >
          <path d="M19 9l1.25-2.75L23 5l-2.75-1.25L19 1l-1.25 2.75L15 5l2.75 1.25L19 9zm-7.5.5L9 4 6.5 9.5 1 12l5.5 2.5L9 20l2.5-5.5L17 12l-5.5-2.5zM19 15l-1.25 2.75L15 19l2.75 1.25L19 23l1.25-2.75L23 19l-2.75-1.25L19 15z" />
        </svg>
      </div>
      <h2 className="text-xl font-bold mb-2">AI Portfolio Assistant</h2>
      <p className="dark:text-slate-400 text-slate-500 text-sm mb-6 max-w-md">
        Ask me anything about your portfolio, stocks, or market trends.
      </p>
      <div className="flex flex-wrap justify-center gap-2">
        {SUGGESTIONS.map((s) => (
          <button
            key={s}
            onClick={() => onSuggestionClick(s)}
            className="text-xs border dark:border-slate-700 border-slate-300 dark:hover:border-slate-500 hover:border-slate-400 rounded-full px-4 py-2 dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 transition-colors"
          >
            {s}
          </button>
        ))}
      </div>
    </div>
  );
}
