import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';

/// Product Card widget — matches "Component/ProductCard" from UI&UX.pen.
///
/// Design spec (from `0miYD`):
///   Layout: vertical flex, cornerRadius 16, fill $bg-surface, clip: true, width 165
///   Children:
///     1. productImage: frame, fill $bg-muted, height 130, fill_container width
///     2. cardContent: vertical flex, gap 6, padding 12, fill_container width
///        a. nouveauBadge: frame, cornerRadius 6, fill $accent-orange, padding [3,8]
///           └─ badgeLabel: text "جديد", Inter 10/700, fill $on-accent
///        b. productName: text, Manrope 14/600, fill $text-primary
///        c. productPrice: text, Manrope 18/800, fill $text-primary, letterSpacing -0.3
///        d. priceLabel: text "à partir de · الجملة", Inter 11, fill $text-secondary
///
/// Interactive features:
///   - Quantity stepper (+ / −): dynamically recalculates price via tiered pricing
///   - "Nouveau / جديد" badge only shows when product.isNew == true
///   - Tap to add to cart
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final ValueChanged<int>? onQuantityChanged;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onQuantityChanged,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 1;

  Product get product => widget.product;

  /// Current unit price — recalculated dynamically based on quantity
  double get _currentPrice => product.priceForQuantity(_quantity);

  /// Whether the price dropped from the base price at current qty
  bool get _hasDiscount => _currentPrice < product.basePrice;

  void _increment() {
    setState(() {
      _quantity++;
      widget.onQuantityChanged?.call(_quantity);
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onQuantityChanged?.call(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // PRODUCT IMAGE (fill $bg-muted, height 130)
          // ═══════════════════════════════════════════════════════════════════
          Container(
            height: 130,
            width: double.infinity,
            color: AppColors.bgMuted,
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // CARD CONTENT (vertical, gap 6, padding 12)
          // ═══════════════════════════════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nouveau / جديد badge ──
                if (product.isNew) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l10n.isDarija ? 'جديد' : 'Nouveau',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // ── Product Name ──
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // ── Dynamic Price (changes with quantity) ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Formatters.price(_currentPrice),
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (_hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        Formatters.price(product.basePrice),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // ── Price label: "à partir de · الجملة" ──
                Text(
                  _hasDiscount
                      ? (l10n.isDarija ? 'ثمن الجملة · gros' : 'prix de gros · الجملة')
                      : (l10n.isDarija ? 'السعر · à partir de' : 'à partir de · الجملة'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Tier breakdown (mini visual) ──
                if (product.sortedTiers.length > 1) ...[
                  _buildTierHints(),
                  const SizedBox(height: 8),
                ],

                // ── Quantity Stepper ──
                _buildQuantityStepper(l10n),
                const SizedBox(height: 8),

                // ── Add to Cart Button ──
                _buildAddToCartButton(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TIER HINTS — shows "10+ → 12.00 DH" breakpoints
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTierHints() {
    final tiers = product.sortedTiers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiers.skip(1).map((tier) {
        final isActive = _quantity >= tier.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.successGreen
                      : AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${tier.key}+ → ${Formatters.price(tier.value)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppColors.successGreen
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // QUANTITY STEPPER — matches Component/StepperButton from UI&UX.pen
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildQuantityStepper(AppLocalizations l10n) {
    return Row(
      children: [
        // ── Minus button ──
        _buildStepperButton(
          symbol: '−',
          onTap: _decrement,
          enabled: _quantity > 1,
        ),
        // ── Quantity display ──
        Expanded(
          child: Center(
            child: Text(
              '$_quantity',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        // ── Plus button ──
        _buildStepperButton(
          symbol: '+',
          onTap: _increment,
          enabled: true,
        ),
      ],
    );
  }

  /// Stepper button — matches Component/StepperButton design:
  ///   cornerRadius 14, fill $bg-surface, height 36, width 36
  ///   symbol: Manrope 24/700, fill $text-primary
  Widget _buildStepperButton({
    required String symbol,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.bgPrimary : AppColors.bgMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADD TO CART BUTTON — orange, full-width, cornerRadius 10
  // PROJECT_CONTEXT.md: "Tap to add to cart" + l10n addToCart
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAddToCartButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: widget.onAddToCart,
      child: Container(
        width: double.infinity,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.accentOrange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            l10n.addToCart,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.textTertiary,
      ),
    );
  }
}
