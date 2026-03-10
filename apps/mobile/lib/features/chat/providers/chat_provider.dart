import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/features/chat/data/chat_repository.dart';
import 'package:vc_stocks_mobile/models/portfolio.dart';

part 'chat_provider.g.dart';

/// A single chat message (user or AI).
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Notifier that owns the chat message list and talks to Gemini via
/// the Firebase AI Logic SDK.
@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  final ChatRepository _repository = ChatRepository();

  @override
  List<ChatMessage> build() => [];

  // ------------------------------------------------------------------
  // System prompt
  // ------------------------------------------------------------------

  String _buildSystemPrompt(Portfolio portfolio) {
    final s = portfolio.summary;
    final holdingsTable = s.byAssetType.entries.expand((entry) {
      return entry.value.holdings.map((h) =>
          '${h.symbol} | ${entry.key} | ${formatNumber(h.shares, decimals: 2)} | '
          '${formatCurrency(h.avgBuyPrice)} | ${formatCurrency(h.currentPrice)} | '
          '${formatCurrency(h.profitLoss)} | ${formatPercent(h.profitLossPercent)}');
    }).join('\n');

    return '''You are a helpful stock market advisor for the VC Stocks portfolio app.
IMPORTANT: You are NOT a licensed financial advisor. Always include a brief disclaimer that your responses are for informational purposes only.

Portfolio: ${portfolio.name}
Total Value: ${formatCurrency(s.totalValue)}
Total Cost: ${formatCurrency(s.totalCost)}
Total P/L: ${formatCurrency(s.totalPL)} (${formatPercent(s.totalPLPercent)})
Day Change: ${formatCurrency(s.dayChange)} (${formatPercent(s.dayChangePercent)})

Holdings:
Symbol | Type | Shares | Avg Price | Current | P/L | P/L%
$holdingsTable

Help the user understand their investments and provide general market insights.
When discussing specific stocks, reference their actual holdings data above.''';
  }

  // ------------------------------------------------------------------
  // Public API
  // ------------------------------------------------------------------

  /// Call once when the chat screen loads.
  void initializeWithPortfolio(Portfolio portfolio) {
    _repository.resetChat();
    _repository.initializeChat(_buildSystemPrompt(portfolio));
    // Keep existing messages so a tab-switch doesn't lose history.
  }

  /// Send a user message and stream the AI response.
  Future<void> sendMessage(String text) async {
    // Append user bubble
    state = [...state, ChatMessage(text: text, isUser: true)];

    // Append empty AI bubble (will be filled by streaming)
    state = [...state, ChatMessage(text: '', isUser: false)];

    try {
      String fullResponse = '';
      await for (final chunk in _repository.sendMessageStream(text)) {
        fullResponse += chunk;
        // Replace the last (AI) message with the growing text
        state = [
          ...state.sublist(0, state.length - 1),
          ChatMessage(text: fullResponse, isUser: false),
        ];
      }
    } catch (e) {
      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(
          text: 'Sorry, an error occurred. Please try again.\n\n$e',
          isUser: false,
        ),
      ];
    }
  }

  /// Whether the AI is currently generating a response.
  bool get isGenerating {
    if (state.isEmpty) return false;
    final last = state.last;
    return !last.isUser && last.text.isEmpty;
  }

  /// Clear history and reset the Gemini session.
  void clearChat() {
    _repository.resetChat();
    state = [];
  }
}
