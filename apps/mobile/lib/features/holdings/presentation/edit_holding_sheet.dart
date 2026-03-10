import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/network/api_exception.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/core/utils/formatters.dart';
import 'package:vc_stocks_mobile/features/holdings/data/holding_repository.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

class EditHoldingSheet extends ConsumerStatefulWidget {
  final HoldingWithPrice holding;
  final VoidCallback onSaved;

  const EditHoldingSheet({
    super.key,
    required this.holding,
    required this.onSaved,
  });

  @override
  ConsumerState<EditHoldingSheet> createState() => _EditHoldingSheetState();
}

class _EditHoldingSheetState extends ConsumerState<EditHoldingSheet> {
  late final TextEditingController _sharesController;
  late final TextEditingController _avgPriceController;
  late final TextEditingController _manualPriceController;
  bool _isLoading = false;
  String? _error;

  static const _iconConstraints = BoxConstraints(
    minWidth: 44,
    minHeight: 44,
  );

  @override
  void initState() {
    super.initState();
    _sharesController =
        TextEditingController(text: widget.holding.shares.toString());
    _avgPriceController =
        TextEditingController(text: widget.holding.avgBuyPrice.toString());
    _manualPriceController = TextEditingController(
      text: widget.holding.manualPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _sharesController.dispose();
    _avgPriceController.dispose();
    _manualPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final shares = double.tryParse(_sharesController.text);
    final avgPrice = double.tryParse(_avgPriceController.text);

    if (shares == null || avgPrice == null) {
      setState(() => _error = 'Invalid shares or price');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final manualPriceText = _manualPriceController.text.trim();
      final manualPrice =
          manualPriceText.isEmpty ? null : double.tryParse(manualPriceText);

      final input = UpdateHoldingInput(
        shares: shares,
        avgBuyPrice: avgPrice,
        manualPrice: manualPrice,
      );

      await ref
          .read(holdingRepositoryProvider)
          .update(widget.holding.id, input);

      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to update holding');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.loss.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.loss, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Delete Holding'),
            ],
          ),
          content: Text(
            'Remove ${widget.holding.symbol} from your portfolio? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.loss.withValues(alpha: 0.1),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.loss),
                child: const Text('Delete'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(holdingRepositoryProvider)
          .delete(widget.holding.id);
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to delete holding');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.holding;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plColor =
        h.profitLoss >= 0 ? AppColors.profit : AppColors.loss;

    // Show name only if it's different from symbol
    final showName =
        h.name.isNotEmpty && h.name.toUpperCase() != h.symbol.toUpperCase();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle — outside scroll area
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding:
                        const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header row ---
                        Row(
                          children: [
                            // Symbol badge
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary
                                        .withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  h.symbol.length > 2
                                      ? h.symbol.substring(0, 2)
                                      : h.symbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title + subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.symbol,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                  ),
                                  if (showName)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2),
                                      child: Text(
                                        h.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(
                                                      alpha: 0.5),
                                            ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Platform badge
                            if (h.platform.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Text(
                                  h.platform,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // --- Current price + P/L card ---
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: plColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  plColor.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Price side
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Price',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(
                                                    alpha: 0.5),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatCurrency(h.currentPrice),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // P/L badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: plColor
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      h.profitLoss >= 0
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color: plColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${h.profitLoss >= 0 ? "+" : ""}${formatCurrency(h.profitLoss)}',
                                      style: TextStyle(
                                        color: plColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Form fields ---
                        const _SectionLabel(label: 'Edit Position'),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _sharesController,
                          decoration: const InputDecoration(
                            labelText: 'Shares',
                            prefixIcon:
                                Icon(Icons.numbers, size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _avgPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Avg Buy Price',
                            prefixIcon: Icon(
                                Icons.attach_money,
                                size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _manualPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Manual Price Override',
                            hintText: 'Leave empty for API price',
                            prefixIcon: Icon(
                                Icons.edit_note_outlined,
                                size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 44, top: 4),
                          child: Text(
                            'Override the live price for assets without API coverage',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4),
                                  fontSize: 11,
                                ),
                          ),
                        ),

                        // Error
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.loss
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.loss
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.loss, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                        color: AppColors.loss,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // --- Action buttons (all 48px height) ---
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
                              // Delete button — same 48px height
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: Material(
                                  color: AppColors.loss
                                      .withValues(alpha: 0.08),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: AppColors.loss
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: _isLoading
                                        ? null
                                        : _handleDelete,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: const Center(
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: AppColors.loss,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Cancel
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Save
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    gradient: _isLoading
                                        ? null
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF667EEA),
                                              Color(0xFF764BA2),
                                            ],
                                          ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleSave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.transparent,
                                      shadowColor:
                                          Colors.transparent,
                                      minimumSize:
                                          const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                                12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Save',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Reusable small section label
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
          ),
    );
  }
}
