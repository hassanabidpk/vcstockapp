"use client";
import ReactMarkdown from "react-markdown";
import type { ChatMessage } from "@/hooks/useChat";

export function ChatMessageBubble({ message }: { message: ChatMessage }) {
  if (message.isUser) {
    return <UserBubble text={message.text} />;
  }
  return <AiBubble text={message.text} />;
}

function UserBubble({ text }: { text: string }) {
  return (
    <div className="flex justify-end mb-3">
      <div
        className="max-w-[78%] rounded-2xl rounded-br-sm px-4 py-2.5 text-sm leading-relaxed text-white"
        style={{
          background: "linear-gradient(135deg, #667EEA 0%, #764BA2 100%)",
        }}
      >
        {text}
      </div>
    </div>
  );
}

function AiBubble({ text }: { text: string }) {
  const isTyping = text === "";

  return (
    <div className="flex gap-2 mb-3 items-start">
      {/* Bot icon */}
      <div className="w-7 h-7 mt-0.5 rounded-lg bg-blue-600/10 flex items-center justify-center flex-shrink-0">
        <svg
          className="w-4 h-4 text-blue-500"
          fill="currentColor"
          viewBox="0 0 24 24"
        >
          <path d="M19 9l1.25-2.75L23 5l-2.75-1.25L19 1l-1.25 2.75L15 5l2.75 1.25L19 9zm-7.5.5L9 4 6.5 9.5 1 12l5.5 2.5L9 20l2.5-5.5L17 12l-5.5-2.5zM19 15l-1.25 2.75L15 19l2.75 1.25L19 23l1.25-2.75L23 19l-2.75-1.25L19 15z" />
        </svg>
      </div>
      {/* Bubble */}
      <div className="max-w-[78%] rounded-2xl rounded-tl-sm px-4 py-2.5 border border-slate-700 dark:bg-slate-800/80 bg-slate-100">
        {isTyping ? (
          <TypingDots />
        ) : (
          <div className="text-sm leading-relaxed dark:text-slate-200 text-slate-800 select-text prose prose-sm dark:prose-invert prose-headings:mt-3 prose-headings:mb-1 prose-p:my-1 prose-ul:my-1 prose-ol:my-1 prose-li:my-0.5 prose-pre:my-2 prose-pre:bg-slate-900 prose-pre:border prose-pre:border-slate-700 prose-code:text-amber-400 prose-code:before:content-none prose-code:after:content-none prose-a:text-blue-400 prose-a:no-underline hover:prose-a:underline prose-blockquote:border-blue-500 prose-strong:text-inherit max-w-none">
            <ReactMarkdown>{text}</ReactMarkdown>
          </div>
        )}
      </div>
    </div>
  );
}

function TypingDots() {
  return (
    <div className="flex gap-1 py-1">
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          className="w-1.5 h-1.5 rounded-full bg-blue-500/50 animate-bounce"
          style={{ animationDelay: `${i * 0.15}s` }}
        />
      ))}
    </div>
  );
}
