import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../providers/supplier_inventory_providers.dart';
import 'supplier_web_shell.dart';

/// Bulk Price Adjustment Modal.
///
/// **Mobile**: Bottom sheet with DraggableScrollableSheet.
/// **Web (Screen F.1)**: Centered dialog (560px) with radio mode selection,
/// input field, full preview table, and action buttons.
/// See UI&UX.pen node `Aer9e` for design reference.
///
/// PROJECT_CONTEXT.md — Bulk Price Adjustment:
///   - Fixed Offset: + / – DH
///   - Percentage Shift: + / – %
///   - Mandatory "Preview Change" step showing Old Price vs New Price
class BulkPriceAdjustmentModal extends ConsumerStatefulWidget {
  final List<Product> selectedProducts;
  final bool isDarija;
  final VoidCallback onApplied;

  const BulkPriceAdjustmentModal({
    super.key,
    required this.selectedProducts,
    required this.isDarija,
    required this.onApplied,
  });

  /// Show as a web dialog (Screen F.1 style) or mobile bottom sheet.
  static void show(
    BuildContext context, {
    required List<Product> products,
    required bool isDarija,
    required VoidCallback onApplied,
  }) {
    if (isWebLayout(context)) {
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 560,
            constraints: const BoxConstraints(maxHeight: 700),
            decoration: BoxDecoration(
              color: AppColors.webCardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: BulkPriceAdjustmentModal(
              selectedProducts: products,
              isDarija: isDarija,
              onApplied: onApplied,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.bgPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => BulkPriceAdjustmentModal(
          selectedProducts: products,
          isDarija: isDarija,
          onApplied: onApplied,
        ),
      );
    }
  }

  @override
  ConsumerState<BulkPriceAdjustmentModal> createState() =>
      _BulkPriceAdjustmentModalState();
}

class _BulkPriceAdjustmentModalState
    extends ConsumerState<BulkPriceAdjustmentModal> {
  BulkAdjustMode _mode = BulkAdjustMode.percentage;
  final TextEditingController _valueController = TextEditingController();
  bool _isPositive = true; // true = increase, false = decrease
  bool _showPreview = false;
  bool _isApplying = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  double get _parsedValue {
    final v = double.tryParse(_valueController.text.trim()) ?? 0;
    return _isPositive ? v : -v;
  }

  BulkPriceUpdate _buildUpdate() {
    return BulkPriceUpdate(
      products: widget.selectedProducts,
      mode: _mode,
      value: _parsedValue,
    );
  }

  /// Preview: compute new tiers for each product.
  List<_ProductPreview> _computePreviews() {
    final update = _buildUpdate();
    return widget.selectedProducts.map((product) {
      final newTiers = update.previewTiers(product);
      return _ProductPreview(
        name: product.name,
        oldBasePrice: product.basePrice,
        newBasePrice: newTiers.isNotEmpty
            ? (newTiers.values.first as num).toDouble()
            : 0,
        oldTiers: product.priceTiers,
        newTiers: newTiers,
      );
    }).toList();
  }

  Future<void> _apply() async {
    setState(() => _isApplying = true);
    try {
      final update = _buildUpdate();
      await ref.read(bulkPriceUpdateProvider(update).future);
      widget.onApplied();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarija = widget.isDarija;

    return DraggableScrollableSheet(
      initialChildSize: _showPreview ? 0.85 : 0.55,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.tune,
                          size: 20, color: AppColors.accentOrange),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDarija ? 'بدل الأثمنة بالجملة' : 'Ajustement groupé',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.selectedProducts.length} ${isDarija ? 'منتوج مختار' : 'produits sélectionnés'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (!_showPreview) ...[
                // ── Mode Selector ──
                _buildModeSelector(isDarija),
                const SizedBox(height: 16),

                // ── Direction toggle (+ / –) ──
                _buildDirectionToggle(isDarija),
                const SizedBox(height: 16),

                // ── Value input ──
                _buildValueInput(isDarija),
                const SizedBox(height: 24),

                // ── Preview button ──
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _valueController.text.trim().isEmpty
                        ? null
                        : () => setState(() => _showPreview = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      disabledBackgroundColor: AppColors.bgMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.preview,
                        color: Colors.white, size: 20),
                    label: Text(
                      isDarija ? 'شوف التغييرات' : 'Aperçu des changements',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // ── Preview Table ──
                _buildPreviewHeader(isDarija),
                const SizedBox(height: 8),
                Expanded(child: _buildPreviewList(isDarija, scrollController)),
                const SizedBox(height: 12),

                // ── Action buttons ──
                Row(
                  children: [
                    // Back button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () =>
                              setState(() => _showPreview = false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.borderSubtle),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            isDarija ? 'رجع' : 'Retour',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply button
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isApplying ? null : _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isApplying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check,
                                  color: Colors.white, size: 20),
                          label: Text(
                            isDarija ? 'طبّق' : 'Appliquer',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MODE SELECTOR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildModeSelector(bool isDarija) {
    return Row(
      children: [
        _buildModeOption(
          label: isDarija ? 'بالنسبة المئوية' : 'Pourcentage',
          sublabel: '+/– %',
          mode: BulkAdjustMode.percentage,
          icon: Icons.percent,
          isDarija: isDarija,
        ),
        const SizedBox(width: 10),
        _buildModeOption(
          label: isDarija ? 'مبلغ ثابت' : 'Montant fixe',
          sublabel: '+/– DH',
          mode: BulkAdjustMode.fixedOffset,
          icon: Icons.attach_money,
          isDarija: isDarija,
        ),
      ],
    );
  }

  Widget _buildModeOption({
    required String label,
    required String sublabel,
    required BulkAdjustMode mode,
    required IconData icon,
    required bool isDarija,
  }) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accentOrange.withOpacity(0.08)
                : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.accentOrange
                  : AppColors.borderSubtle,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22,
                  color: selected
                      ? AppColors.accentOrange
                      : AppColors.textTertiary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.accentOrange
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: selected
                      ? AppColors.accentOrange
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DIRECTION TOGGLE (+ / –)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDirectionToggle(bool isDarija) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isPositive = true),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _isPositive
                    ? AppColors.successGreen.withOpacity(0.12)
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPositive
                      ? AppColors.successGreen
                      : AppColors.borderSubtle,
                ),
              ),
              child: Center(
                child: Text(
                  isDarija ? '⬆ زيد' : '⬆ Augmenter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isPositive
                        ? AppColors.successGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isPositive = false),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: !_isPositive
                    ? AppColors.alertRed.withOpacity(0.12)
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_isPositive
                      ? AppColors.alertRed
                      : AppColors.borderSubtle,
                ),
              ),
              child: Center(
                child: Text(
                  isDarija ? '⬇ نقص' : '⬇ Diminuer',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_isPositive
                        ? AppColors.alertRed
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // VALUE INPUT
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildValueInput(bool isDarija) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textTertiary.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _mode == BulkAdjustMode.percentage ? '%' : 'DH',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PREVIEW HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildPreviewHeader(bool isDarija) {
    final sign = _isPositive ? '+' : '–';
    final val = _valueController.text.trim();
    final unit = _mode == BulkAdjustMode.percentage ? '%' : ' DH';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentOrange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 18, color: AppColors.accentOrange),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: isDarija ? 'التعديل: ' : 'Modification: ',
                  ),
                  TextSpan(
                    text: '$sign$val$unit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _isPositive
                          ? AppColors.successGreen
                          : AppColors.alertRed,
                    ),
                  ),
                  TextSpan(
                    text: isDarija
                        ? ' على ${widget.selectedProducts.length} منتوج'
                        : ' sur ${widget.selectedProducts.length} produits',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PREVIEW LIST — Old Price vs New Price
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildPreviewList(bool isDarija, ScrollController controller) {
    final previews = _computePreviews();

    return ListView.separated(
      controller: controller,
      itemCount: previews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final preview = previews[i];
        final priceUp = preview.newBasePrice >= preview.oldBasePrice;
        final diff = preview.newBasePrice - preview.oldBasePrice;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name
              Text(
                preview.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Old vs New base price
              Row(
                children: [
                  // Old price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDarija ? 'الثمن القديم' : 'Ancien prix',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          Formatters.price(preview.oldBasePrice),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward,
                        size: 16, color: AppColors.textTertiary),
                  ),

                  // New price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDarija ? 'الثمن الجديد' : 'Nouveau prix',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          Formatters.price(preview.newBasePrice),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: priceUp
                                ? AppColors.successGreen
                                : AppColors.alertRed,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Diff badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (priceUp
                              ? AppColors.successGreen
                              : AppColors.alertRed)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${diff >= 0 ? '+' : ''}${Formatters.price(diff)}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: priceUp
                            ? AppColors.successGreen
                            : AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
              ),

              // Tier breakdown (collapsed by default for clarity)
              if (preview.newTiers.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: preview.newTiers.entries.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${e.key}+ → ${Formatters.price((e.value as num).toDouble())}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper model for preview computation.
class _ProductPreview {
  final String name;
  final double oldBasePrice;
  final double newBasePrice;
  final Map<String, dynamic> oldTiers;
  final Map<String, dynamic> newTiers;

  _ProductPreview({
    required this.name,
    required this.oldBasePrice,
    required this.newBasePrice,
    required this.oldTiers,
    required this.newTiers,
  });
}
