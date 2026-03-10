import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_stocks_mobile/core/constants/app_constants.dart';
import 'package:vc_stocks_mobile/core/network/api_exception.dart';
import 'package:vc_stocks_mobile/core/theme/app_theme.dart';
import 'package:vc_stocks_mobile/features/holdings/data/holding_repository.dart';
import 'package:vc_stocks_mobile/models/holding.dart';

class AddHoldingSheet extends ConsumerStatefulWidget {
  final String portfolioId;
  final String? prefillSymbol;
  final String? prefillName;
  final AssetType? prefillAssetType;
  final VoidCallback onSaved;

  const AddHoldingSheet({
    super.key,
    required this.portfolioId,
    this.prefillSymbol,
    this.prefillName,
    this.prefillAssetType,
    required this.onSaved,
  });

  @override
  ConsumerState<AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<AddHoldingSheet> {
  late AssetType _assetType;
  late final TextEditingController _symbolController;
  late final TextEditingController _nameController;
  final _sharesController = TextEditingController();
  final _avgPriceController = TextEditingController();
  String _platform = kPlatformOptions.first;
  final _customPlatformController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  static const _iconConstraints = BoxConstraints(
    minWidth: 44,
    minHeight: 44,
  );

  @override
  void initState() {
    super.initState();
    _assetType = widget.prefillAssetType ?? AssetType.usStock;
    _symbolController =
        TextEditingController(text: widget.prefillSymbol ?? '');
    _nameController = TextEditingController(text: widget.prefillName ?? '');
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _sharesController.dispose();
    _avgPriceController.dispose();
    _customPlatformController.dispose();
    super.dispose();
  }

  String get _symbolHint {
    switch (_assetType) {
      case AssetType.usStock:
        return 'e.g. AAPL';
      case AssetType.sgStock:
        return 'e.g. D05.SI';
      case AssetType.crypto:
        return 'e.g. bitcoin';
    }
  }

  Future<void> _handleSubmit() async {
    final symbol = _symbolController.text.trim();
    final name = _nameController.text.trim();
    final shares = double.tryParse(_sharesController.text);
    final avgPrice = double.tryParse(_avgPriceController.text);

    if (symbol.isEmpty || name.isEmpty || shares == null || avgPrice == null) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final platform = _platform == 'Other'
          ? _customPlatformController.text.trim()
          : _platform;
      final currency = _assetType == AssetType.sgStock ? 'SGD' : 'USD';

      final input = CreateHoldingInput(
        symbol: symbol.toUpperCase(),
        name: name,
        assetType: _assetType,
        shares: shares,
        avgBuyPrice: avgPrice,
        currency: currency,
        platform: platform,
      );

      await ref.read(holdingRepositoryProvider).create(
            widget.portfolioId,
            input,
          );

      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to add holding');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
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
                // Drag handle — outside scroll area so it's always visible
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
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add_chart,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add Holding',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- Asset type section ---
                        const _SectionLabel(label: 'Asset Type'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AssetType>(
                            segments: const [
                              ButtonSegment(
                                value: AssetType.usStock,
                                label: Text('US Stock'),
                              ),
                              ButtonSegment(
                                value: AssetType.sgStock,
                                label: Text('SG Stock'),
                              ),
                              ButtonSegment(
                                value: AssetType.crypto,
                                label: Text('Crypto'),
                              ),
                            ],
                            selected: {_assetType},
                            onSelectionChanged: (selected) {
                              setState(() => _assetType = selected.first);
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Details section ---
                        const _SectionLabel(label: 'Details'),
                        const SizedBox(height: 12),

                        // Symbol
                        TextField(
                          controller: _symbolController,
                          decoration: InputDecoration(
                            labelText: 'Symbol',
                            hintText: _symbolHint,
                            prefixIcon: const Icon(Icons.tag, size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 16),

                        // Name
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon:
                                Icon(Icons.label_outline, size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Shares + Avg Price side by side
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _sharesController,
                                decoration: const InputDecoration(
                                  labelText: 'Shares',
                                  prefixIcon:
                                      Icon(Icons.numbers, size: 18),
                                  prefixIconConstraints: _iconConstraints,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _avgPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Avg Price',
                                  prefixIcon: Icon(
                                      Icons.attach_money,
                                      size: 18),
                                  prefixIconConstraints: _iconConstraints,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Platform
                        DropdownButtonFormField<String>(
                          initialValue: _platform,
                          decoration: const InputDecoration(
                            labelText: 'Platform',
                            prefixIcon:
                                Icon(Icons.business, size: 18),
                            prefixIconConstraints: _iconConstraints,
                          ),
                          items: kPlatformOptions
                              .map((p) => DropdownMenuItem(
                                  value: p, child: Text(p)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _platform = value);
                            }
                          },
                        ),
                        if (_platform == 'Other') ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _customPlatformController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Platform',
                              prefixIcon:
                                  Icon(Icons.edit, size: 18),
                              prefixIconConstraints: _iconConstraints,
                            ),
                          ),
                        ],

                        // Error
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.loss.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
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

                        // --- Action buttons (fixed 48px height) ---
                        SizedBox(
                          height: 48,
                          child: Row(
                            children: [
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
                                        : _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize:
                                          const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
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
                                            'Add Holding',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
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
