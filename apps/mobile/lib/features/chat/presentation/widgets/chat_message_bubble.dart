import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/features/chat/providers/chat_provider.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isUser) {
      return _UserBubble(message: message);
    }
    return _AiBubble(message: message, isDark: isDark);
  }
}

// -----------------------------------------------------------------------
// User bubble — right-aligned, gradient background
// -----------------------------------------------------------------------

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: const Radius.circular(4),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------
// AI bubble — left-aligned, surface background, markdown rendered
// -----------------------------------------------------------------------

class _AiBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  const _AiBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isTyping = message.text.isEmpty;
    final textColor = isDark ? Colors.white : Colors.black87;
    final codeBlockBg =
        isDark ? AppColors.darkBackground : Colors.grey.shade200;
    final codeBorder = isDark ? AppColors.darkBorder : Colors.grey.shade300;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot icon
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          // Message bubble
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: const Radius.circular(4),
                ),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : Colors.grey.shade200,
                ),
              ),
              child: isTyping
                  ? const _TypingIndicator()
                  : MarkdownBody(
                      data: message.text,
                      selectable: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(Uri.parse(href),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      styleSheet: MarkdownStyleSheet(
                        // Base text
                        p: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: textColor,
                        ),
                        // Bold
                        strong: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        // Italic
                        em: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: textColor,
                        ),
                        // Links
                        a: const TextStyle(
                          color: AppColors.primaryLight,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryLight,
                        ),
                        // Headings
                        h1: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.4,
                        ),
                        h2: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.4,
                        ),
                        h3: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.4,
                        ),
                        // Inline code
                        code: TextStyle(
                          fontSize: 13,
                          fontFamily: 'monospace',
                          color: AppColors.amber,
                          backgroundColor: codeBlockBg,
                        ),
                        // Code blocks
                        codeblockDecoration: BoxDecoration(
                          color: codeBlockBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: codeBorder),
                        ),
                        codeblockPadding: const EdgeInsets.all(12),
                        // Blockquote
                        blockquoteDecoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        blockquotePadding:
                            const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                        // Lists
                        listBullet: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                        // Horizontal rule
                        horizontalRuleDecoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                        // Table
                        tableHead: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor,
                        ),
                        tableBody: TextStyle(
                          fontSize: 13,
                          color: textColor,
                        ),
                        tableBorder: TableBorder.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                        tableCellsPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Typing dots animation
// -----------------------------------------------------------------------

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t =
                ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final offset = (t < 0.5 ? t : 1.0 - t) * -6;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
