import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/cart_providers.dart';

/// ══════════════════════════════════════════════════════════════════════════════
/// RETAILER CART SCREEN — Shopping cart + Order Confirmation + WhatsApp Share.
///
/// Flow:
///   1. Displays cart line items with live tiered prices
///   2. Optional notes field for retailer message
///   3. "Confirm Order" → inserts into orders table (status=pending)
///   4. On success → shows confirmation bottom sheet with WhatsApp share
///
/// Design Reference:
///   Follows UI&UX.pen design system tokens:
///   - bg-primary (#FAF9F7), bg-surface (#E7E5E4), bg-dark (#2D2D2D)
///   - accent-orange (#C2410C) for primary actions
///   - success-green (#10B981) for confirmation states
///   - Manrope headings, Inter body
/// ══════════════════════════════════════════════════════════════════════════════
class RetailerCartScreen extends ConsumerStatefulWidget {
  final String supplierId;
  final String? supplierName;
  final String? supplierPhone;
  final String relationId;

  const RetailerCartScreen({
    super.key,
    required this.supplierId,
    required this.relationId,
    this.supplierName,
    this.supplierPhone,
  });

  @override
  ConsumerState<RetailerCartScreen> createState() => _RetailerCartScreenState();
}

class _RetailerCartScreenState extends ConsumerState<RetailerCartScreen> {
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(cartItemsProvider);
    final total = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: items.isEmpty
            ? _buildEmptyState(l10n)
            : Column(
                children: [
                  // ── Header ──
                  _buildHeader(l10n, itemCount),

                  // ── Supplier info bar ──
                  if (widget.supplierName != null)
                    _buildSupplierBar(l10n),

                  // ── Cart items list ──
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildCartItem(items[index], l10n),
                    ),
                  ),

                  // ── Notes field ──
                  _buildNotesField(l10n),

                  // ── Order summary + Confirm button ──
                  _buildBottomBar(l10n, total, itemCount),
                ],
              ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(AppLocalizations l10n, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cart,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$itemCount ${l10n.items}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Clear cart
          TextButton.icon(
            onPressed: () => _showClearCartDialog(l10n),
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppColors.alertRed),
            label: Text(
              l10n.clearCart,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.alertRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPLIER INFO BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSupplierBar(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store_rounded,
                size: 18, color: AppColors.accentOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.supplierName ?? '',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            l10n.orderFor,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART ITEM
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCartItem(CartItem item, AppLocalizations l10n) {
    final hasDiscount = item.unitPrice < item.product.basePrice;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgSurface),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.textTertiary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      Formatters.price(item.unitPrice),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        Formatters.price(item.product.basePrice),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.lineTotal}: ${Formatters.price(item.lineTotal)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Quantity stepper
          Column(
            children: [
              _buildStepperButton(
                icon: Icons.add,
                onTap: () => ref.read(cartProvider.notifier).increment(item.productId),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: item.quantity > 1
                    ? Icons.remove
                    : Icons.delete_outline_rounded,
                color: item.quantity > 1
                    ? AppColors.textPrimary
                    : AppColors.alertRed,
                onTap: () => ref.read(cartProvider.notifier).decrement(item.productId),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color ?? AppColors.textPrimary),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTES FIELD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildNotesField(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _notesController,
        maxLines: 2,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.orderNotes,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.bgSurface),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.bgSurface),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.accentOrange, width: 1.5),
          ),
          prefixIcon: const Icon(Icons.note_alt_outlined,
              size: 20, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM BAR — Summary + Confirm
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(AppLocalizations l10n, double total, int itemCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.bgSurface),
        ),
      ),
      child: Column(
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderTotal,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                Formatters.price(total),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmOrder(l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.onAccent,
                disabledBackgroundColor: AppColors.bgMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.onAccent),
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: Text(
                _isSubmitting ? l10n.loading : l10n.confirmOrder,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyCart,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptyCartSubtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(l10n.backToCatalog),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accentOrange,
              textStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIRM ORDER (Order Handshake)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _confirmOrder(AppLocalizations l10n) async {
    final items = ref.read(cartItemsProvider);
    if (items.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final total = ref.read(cartTotalProvider);
      final notes = _notesController.text.trim();

      // Build OrderItem JSONB array
      final orderItems = items
          .map((item) => OrderItem(
                productId: item.productId,
                name: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                lineTotal: item.lineTotal,
              ))
          .toList();

      // Create Order with status=pending
      final order = Order(
        id: '', // generated by Supabase
        supplierId: widget.supplierId,
        retailerId: '', // set by RLS — will be current user
        relationId: widget.relationId,
        items: orderItems,
        originalTotal: total,
        status: 'pending',
        notes: notes.isNotEmpty ? notes : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(orderRepositoryProvider);
      final createdOrder = await repo.create(order);

      // Clear the cart
      ref.read(cartProvider.notifier).clear();
      _notesController.clear();

      if (mounted) {
        _showOrderConfirmation(l10n, createdOrder);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER CONFIRMATION BOTTOM SHEET (with WhatsApp share)
  // ═══════════════════════════════════════════════════════════════════════════

  void _showOrderConfirmation(AppLocalizations l10n, Order order) {
    // Read the retailer's shop name for the WhatsApp message
    final profile = ref.read(currentProfileProvider).valueOrNull;
    final retailerName = profile?.shopName ?? '';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderConfirmationSheet(
        l10n: l10n,
        order: order,
        supplierName: widget.supplierName,
        supplierPhone: widget.supplierPhone,
        retailerName: retailerName,
        onDone: () {
          Navigator.of(ctx).pop();
          // Navigate back to dashboard
          context.go('/retailer/dashboard');
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEAR CART DIALOG
  // ═══════════════════════════════════════════════════════════════════════════

  void _showClearCartDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.clearCart,
          style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.clearCartConfirm,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.alertRed),
            child: Text(l10n.clearCart),
          ),
        ],
      ),
    );
  }
}

/// ════════════════════════════════════════════════════════════════════════════
/// ORDER CONFIRMATION SHEET — Shown after successful order creation.
/// Features: Success animation, order summary, WhatsApp deep-link share.
/// ════════════════════════════════════════════════════════════════════════════
class _OrderConfirmationSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final Order order;
  final String? supplierName;
  final String? supplierPhone;
  final String retailerName;
  final VoidCallback onDone;

  const _OrderConfirmationSheet({
    required this.l10n,
    required this.order,
    required this.onDone,
    required this.retailerName,
    this.supplierName,
    this.supplierPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Success icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.orderConfirmed,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.orderConfirmedSubtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Order summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.bgSurface),
                ),
                child: Column(
                  children: [
                    _summaryRow(l10n.orderNumber,
                        '#${order.id.substring(0, 8).toUpperCase()}'),
                    const SizedBox(height: 8),
                    _summaryRow(
                        '${l10n.items} (${order.itemCount})',
                        '${order.totalPieces} ${l10n.pieces}'),
                    const SizedBox(height: 8),
                    _summaryRow(
                      l10n.orderTotal,
                      Formatters.price(order.originalTotal),
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _summaryRow(
                      l10n.statusLabel('pending'),
                      '⏳',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── WhatsApp Share Button ──
              if (supplierPhone != null && supplierPhone!.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareOnWhatsApp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp green
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: Text(
                      l10n.shareOnWhatsApp,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Done button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onDone,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.bgSurface),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l10n.backToDashboard,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.accentOrange : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WHATSAPP DEEP-LINK
  //
  // Template (Moroccan B2B norms):
  //   السلام عليكم
  //   Nouvelle Commande: #A1B2C3D4
  //   Client: Boutique Al Najah
  //   ------------------
  //   • 50x Câble USB-C (10.00 DH)
  //   • 20x Coque iPhone 13 (15.00 DH)
  //   ------------------
  //   Total Estimé: 890.00 DH
  //
  // Why this format:
  //   - Salaam: Standard Moroccan business greeting
  //   - Bullet points: Suppliers scan quantities fast
  //   - Order ID: For dispute resolution / DB lookup
  //   - "Total Estimé": Partial Receipt may adjust the final amount later
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _shareOnWhatsApp(BuildContext context) async {
    // Build item maps for the message generator
    final itemMaps = order.items
        .map((item) => <String, dynamic>{
              'qty': item.quantity,
              'name': item.name,
              'price_per_unit': item.unitPrice,
            })
        .toList();

    final message = Formatters.generateWhatsAppOrderMessage(
      orderId: order.id,
      retailerName: retailerName,
      items: itemMaps,
      totalAmount: order.originalTotal,
      notes: order.notes,
    );

    final url = Formatters.whatsappLink(
      phone: supplierPhone!,
      message: message,
    );

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
