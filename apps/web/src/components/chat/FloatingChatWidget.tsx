"use client";
import { useState, useEffect, useRef } from "react";
import { usePathname } from "next/navigation";
import { usePortfolioContext } from "@/context/PortfolioContext";
import { usePortfolio } from "@/hooks/usePortfolio";
import { useChat } from "@/hooks/useChat";
import { ChatMessageBubble } from "./ChatMessageBubble";
import { ChatInput } from "./ChatInput";

const HIDDEN_PATHS = ["/chat", "/login"];

export function FloatingChatWidget() {
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);
  const { activePortfolio } = usePortfolioContext();
  const { portfolio } = usePortfolio(activePortfolio?.id ?? null);
  const { messages, sendMessage, isGenerating, clearChat } = useChat(portfolio);
  const bottomRef = useRef<HTMLDivElement>(null);

  // Auto-scroll on new messages — ALL hooks must be above any conditional return
  useEffect(() => {
    if (isOpen) {
      bottomRef.current?.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages, isOpen]);

  // Hide on certain pages — AFTER all hooks
  if (HIDDEN_PATHS.includes(pathname ?? "")) return null;

  return (
    <>
      {/* Floating button */}
      {!isOpen && (
        <button
          onClick={() => setIsOpen(true)}
          className="fixed bottom-6 right-6 z-50 w-14 h-14 rounded-full shadow-lg shadow-purple-500/20 flex items-center justify-center transition-transform hover:scale-105"
          style={{
            background: "linear-gradient(135deg, #667EEA 0%, #764BA2 100%)",
          }}
        >
          <svg
            className="w-6 h-6 text-white"
            fill="currentColor"
            viewBox="0 0 24 24"
          >
            <path d="M19 9l1.25-2.75L23 5l-2.75-1.25L19 1l-1.25 2.75L15 5l2.75 1.25L19 9zm-7.5.5L9 4 6.5 9.5 1 12l5.5 2.5L9 20l2.5-5.5L17 12l-5.5-2.5zM19 15l-1.25 2.75L15 19l2.75 1.25L19 23l1.25-2.75L23 19l-2.75-1.25L19 15z" />
          </svg>
        </button>
      )}

      {/* Chat panel */}
      {isOpen && (
        <div className="fixed bottom-6 right-6 z-50 w-96 h-[500px] dark:bg-slate-900 bg-white border dark:border-slate-700 border-slate-200 rounded-2xl shadow-2xl flex flex-col overflow-hidden transition-colors">
          {/* Header */}
          <div className="flex items-center justify-between px-4 py-3 border-b dark:border-slate-800 border-slate-200">
            <div className="flex items-center gap-2">
              <div
                className="w-6 h-6 rounded-md flex items-center justify-center"
                style={{
                  background:
                    "linear-gradient(135deg, #667EEA 0%, #764BA2 100%)",
                }}
              >
                <svg
                  className="w-3.5 h-3.5 text-white"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M19 9l1.25-2.75L23 5l-2.75-1.25L19 1l-1.25 2.75L15 5l2.75 1.25L19 9zm-7.5.5L9 4 6.5 9.5 1 12l5.5 2.5L9 20l2.5-5.5L17 12l-5.5-2.5zM19 15l-1.25 2.75L15 19l2.75 1.25L19 23l1.25-2.75L23 19l-2.75-1.25L19 15z" />
                </svg>
              </div>
              <span className="text-sm font-semibold">AI Chat</span>
            </div>
            <div className="flex items-center gap-1">
              {messages.length > 0 && (
                <button
                  onClick={clearChat}
                  className="p-1.5 dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 transition-colors"
                  title="Clear chat"
                >
                  <svg
                    className="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                    strokeWidth={1.5}
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0"
                    />
                  </svg>
                </button>
              )}
              <button
                onClick={() => setIsOpen(false)}
                className="p-1.5 dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 transition-colors"
                title="Close"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  strokeWidth={2}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </div>
          </div>

          {/* Messages */}
          <div className="flex-1 overflow-y-auto px-3 py-3">
            {messages.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center">
                <p className="text-xs text-slate-500 mb-3">
                  Ask about your portfolio
                </p>
                <div className="flex flex-wrap justify-center gap-1.5">
                  {[
                    "How is my portfolio?",
                    "Top performers?",
                    "Diversification tips",
                  ].map((s) => (
                    <button
                      key={s}
                      onClick={() => sendMessage(s)}
                      className="text-[11px] border dark:border-slate-700 border-slate-300 dark:hover:border-slate-500 hover:border-slate-400 rounded-full px-3 py-1.5 dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 transition-colors"
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
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
      )}
    </>
  );
}
