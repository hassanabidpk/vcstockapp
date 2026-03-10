import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:vc_stocks_mobile/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:vc_stocks_mobile/features/chat/providers/chat_provider.dart';
import 'package:vc_stocks_mobile/features/dashboard/providers/portfolio_detail_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// True when the user is within 150px of the bottom.
  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final pos = _scrollController.position;
    return pos.maxScrollExtent - pos.pixels < 150;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioDetailProvider);
    final messages = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize chat when portfolio loads
    portfolioAsync.whenData((portfolio) {
      if (portfolio != null) {
        chatNotifier.initializeWithPortfolio(portfolio);
      }
    });

    // Only auto-scroll when a new message is added (user sent or AI started),
    // or when the user is already near the bottom. This prevents yanking
    // the view away while the user is reading mid-scroll during streaming.
    if (messages.length != _previousMessageCount) {
      _previousMessageCount = messages.length;
      _scrollToBottom();
    } else if (_isNearBottom()) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text('AI Chat'),
          ],
        ),
        actions: [
          if (messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Clear chat',
              onPressed: () {
                chatNotifier.clearChat();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageBubble(message: messages[index]);
                    },
                  ),
          ),
          // Input field
          ChatInputField(
            enabled: !chatNotifier.isGenerating,
            onSubmit: (text) {
              chatNotifier.sendMessage(text);
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Empty state — shown before any messages
// -----------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'AI Portfolio Assistant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your portfolio, stocks, or market trends.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  label: 'How is my portfolio doing?',
                  isDark: isDark,
                ),
                _SuggestionChip(
                  label: 'Which stocks are underperforming?',
                  isDark: isDark,
                ),
                _SuggestionChip(
                  label: 'Suggest diversification strategies',
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SuggestionChip({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Find the ChatScreen ancestor and trigger a send
        final chatNotifier =
            ProviderScope.containerOf(context).read(chatNotifierProvider.notifier);
        chatNotifier.sendMessage(label);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          ),
          color: isDark
              ? AppColors.darkSurface
              : Colors.grey.shade50,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
