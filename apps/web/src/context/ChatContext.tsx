"use client";
import {
  createContext,
  useContext,
  useState,
  useCallback,
  useRef,
  type ReactNode,
} from "react";
import { getFirebaseApp } from "@/lib/firebase";
import { getAI, getGenerativeModel, type ChatSession } from "firebase/ai";
import { usePortfolioContext } from "./PortfolioContext";
import { usePortfolio } from "@/hooks/usePortfolio";
import type { PortfolioData } from "@/lib/api-client";

export interface ChatMessage {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
}

interface ChatContextValue {
  messages: ChatMessage[];
  sendMessage: (text: string) => Promise<void>;
  isGenerating: boolean;
  clearChat: () => void;
}

const ChatContext = createContext<ChatContextValue>({
  messages: [],
  sendMessage: async () => {},
  isGenerating: false,
  clearChat: () => {},
});

function buildSystemPrompt(portfolio: PortfolioData): string {
  const s = portfolio.summary;
  const holdingsRows = Object.entries(s.byAssetType)
    .flatMap(([type, group]) =>
      group.holdings.map(
        (h) =>
          `${h.symbol} | ${type} | ${h.shares} | $${h.avgBuyPrice.toFixed(2)} | $${h.currentPrice.toFixed(2)} | $${h.profitLoss.toFixed(2)} | ${h.profitLossPercent.toFixed(1)}%`
      )
    )
    .join("\n");

  return `You are a helpful stock market advisor for the VC Stocks portfolio app.
IMPORTANT: You are NOT a licensed financial advisor. Always include a brief disclaimer that your responses are for informational purposes only.

Portfolio: ${portfolio.name}
Total Value: $${s.totalValue.toFixed(2)}
Total Cost: $${s.totalCost.toFixed(2)}
Total P/L: $${s.totalPL.toFixed(2)} (${s.totalPLPercent.toFixed(1)}%)
Day Change: $${s.dayChange.toFixed(2)} (${s.dayChangePercent.toFixed(1)}%)

Holdings:
Symbol | Type | Shares | Avg Price | Current | P/L | P/L%
${holdingsRows}

Help the user understand their investments and provide general market insights.
When discussing specific stocks, reference their actual holdings data above.`;
}

let nextId = 1;
function createId(): string {
  return `msg_${nextId++}_${Date.now()}`;
}

export function ChatProvider({ children }: { children: ReactNode }) {
  const { activePortfolio } = usePortfolioContext();
  const { portfolio } = usePortfolio(activePortfolio?.id ?? null);

  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isGenerating, setIsGenerating] = useState(false);
  const chatSessionRef = useRef<ChatSession | null>(null);
  const initializedForRef = useRef<string | null>(null);

  const ensureSession = useCallback(() => {
    if (!portfolio) return null;
    if (initializedForRef.current === portfolio.id && chatSessionRef.current) {
      return chatSessionRef.current;
    }

    const app = getFirebaseApp();
    const ai = getAI(app);
    const model = getGenerativeModel(ai, {
      model: "gemini-3-flash-preview",
      systemInstruction: buildSystemPrompt(portfolio),
    });
    chatSessionRef.current = model.startChat();
    initializedForRef.current = portfolio.id;
    return chatSessionRef.current;
  }, [portfolio]);

  const sendMessage = useCallback(
    async (text: string) => {
      const session = ensureSession();
      if (!session) return;

      const userMsg: ChatMessage = {
        id: createId(),
        text,
        isUser: true,
        timestamp: new Date(),
      };
      const aiMsgId = createId();
      const aiMsg: ChatMessage = {
        id: aiMsgId,
        text: "",
        isUser: false,
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, userMsg, aiMsg]);
      setIsGenerating(true);

      try {
        const result = await session.sendMessageStream(text);
        let fullText = "";
        for await (const chunk of result.stream) {
          const chunkText = chunk.text();
          if (chunkText) {
            fullText += chunkText;
            const currentFull = fullText;
            setMessages((prev) =>
              prev.map((m) =>
                m.id === aiMsgId ? { ...m, text: currentFull } : m
              )
            );
          }
        }
      } catch (err) {
        setMessages((prev) =>
          prev.map((m) =>
            m.id === aiMsgId
              ? { ...m, text: `Sorry, an error occurred. Please try again.\n\n${err}` }
              : m
          )
        );
      } finally {
        setIsGenerating(false);
      }
    },
    [ensureSession]
  );

  const clearChat = useCallback(() => {
    setMessages([]);
    chatSessionRef.current = null;
    initializedForRef.current = null;
  }, []);

  return (
    <ChatContext.Provider value={{ messages, sendMessage, isGenerating, clearChat }}>
      {children}
    </ChatContext.Provider>
  );
}

export function useChatContext() {
  return useContext(ChatContext);
}
