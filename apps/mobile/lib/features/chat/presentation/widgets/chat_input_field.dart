import 'package:flutter/material.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';

class ChatInputField extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool enabled;

  const ChatInputField({
    super.key,
    required this.onSubmit,
    this.enabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _hasText => _controller.text.trim().isNotEmpty;

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSubmit(text);
    _controller.clear();
    setState(() {}); // refresh send button state
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSubmit(),
              maxLines: 4,
              minLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about your portfolio...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : Colors.grey.shade500,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: (_hasText && widget.enabled) ? _handleSubmit : null,
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: (_hasText && widget.enabled)
                      ? const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        )
                      : null,
                  color: (_hasText && widget.enabled)
                      ? null
                      : (isDark ? AppColors.darkBorder : Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: (_hasText && widget.enabled)
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextMuted
                          : Colors.grey.shade500),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
