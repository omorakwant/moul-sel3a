import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../providers/supplier_inventory_providers.dart';
import 'bulk_price_adjustment_modal.dart';
import 'supplier_web_shell.dart';

/// Supplier Inventory List Screen.
///
/// **Mobile**: Card list with search, brand filter, multi-select mode.
/// **Web (>1024px)**: Data table with sidebar (Screen F — "The Command Center").
/// See UI&UX.pen node `dZFuG` for design reference.
class SupplierInventoryScreen extends ConsumerStatefulWidget {
  const SupplierInventoryScreen({super.key});

  @override
  ConsumerState<SupplierInventoryScreen> createState() =>
      _SupplierInventoryScreenState();
}

class _SupplierInventoryScreenState
    extends ConsumerState<SupplierInventoryScreen> {
  String _searchQuery = '';
  String? _brandFilter;
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  bool get _isDarija => ref.watch(localeProvider) == 'ar';

  void _toggleSelectMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) _selectedIds.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Product> products) {
    setState(() {
      if (_selectedIds.length == products.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(products.map((p) => p.id));
      }
    });
  }

  List<Product> _applyFilters(List<Product> products) {
    var filtered = products;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.brand?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (_brandFilter != null) {
      filtered =
          filtered.where((p) => p.brand == _brandFilter).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDarija = _isDarija;
    final productsAsync = ref.watch(supplierProductsProvider);
    final useWeb = isWebLayout(context);

    // On web, wrap in sidebar shell and use data table layout
    if (useWeb) {
      return SupplierWebShell(
        activeRoute: 'supplier-inventory',
        child: _buildWebLayout(isDarija, productsAsync),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarija),
            _buildSearchBar(isDarija),
            _buildBrandChips(isDarija),

            // Selection toolbar
            if (_isSelecting) _buildSelectionToolbar(isDarija),

            // Product list
            Expanded(
              child: productsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accentOrange),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 40, color: AppColors.alertRed),
                      const SizedBox(height: 8),
                      Text(
                        isDarija ? 'مشكل فالتحميل' : 'Erreur de chargement',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(supplierProductsProvider),
                        child: Text(
                          isDarija ? 'عاود' : 'Réessayer',
                          style: const TextStyle(
                              color: AppColors.accentOrange),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (products) {
                  final filtered = _applyFilters(products);
                  if (filtered.isEmpty) {
                    return _buildEmptyState(isDarija, products.isEmpty);
                  }
                  return RefreshIndicator(
                    color: AppColors.accentOrange,
                    onRefresh: () async {
                      ref.invalidate(supplierProductsProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (ctx, i) =>
                          _buildProductCard(filtered[i], isDarija),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB: Add product
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.go('/supplier/product/add'),
              backgroundColor: AppColors.accentOrange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isDarija ? 'زيد منتوج' : 'Nouveau produit',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // WEB DATA TABLE LAYOUT (Screen F — "The Command Center")
  // UI&UX.pen nodes: dZFuG (main), LlV2T (bulk bar), Aer9e (modal)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(bool isDarija, AsyncValue<List<Product>> productsAsync) {
    return Column(
      children: [
        // ── TopBar (64px) ──
        _buildWebTopBar(isDarija),

        // ── Content ──
        Expanded(
          child: Stack(
            children: [
              productsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accentOrange),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: AppColors.alertRed),
                      const SizedBox(height: 8),
                      Text(isDarija ? 'مشكل فالتحميل' : 'Erreur de chargement'),
                      TextButton(
                        onPressed: () => ref.invalidate(supplierProductsProvider),
                        child: Text(isDarija ? 'عاود' : 'Réessayer'),
                      ),
                    ],
                  ),
                ),
                data: (products) {
                  final filtered = _applyFilters(products);
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.webCardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.webCardBorder),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Filter tabs
                          _buildWebFilterTabs(isDarija),
                          // Table header
                          _buildWebTableHeader(isDarija),
                          // Table rows
                          Expanded(
                            child: filtered.isEmpty
                                ? _buildEmptyState(isDarija, products.isEmpty)
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (ctx, i) =>
                                        _buildWebTableRow(filtered[i], isDarija),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ── Floating Bulk Action Bar ──
              if (_isSelecting && _selectedIds.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(child: _buildWebBulkBar(isDarija)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebTopBar(bool isDarija) {
    final productsAsync = ref.watch(supplierProductsProvider);
    final count = productsAsync.valueOrNull?.length ?? 0;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.webCardBg,
        border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
      ),
      child: Row(
        children: [
          // Title + badge
          Text(
            isDarija ? 'المخزون' : 'Inventaire',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count ${isDarija ? 'منتوج' : 'produits'}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),

          // Search
          SizedBox(
            width: 240,
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              decoration: InputDecoration(
                hintText: isDarija ? 'قلّب...' : 'Rechercher...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                filled: true,
                fillColor: const Color(0xFFF5F5F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter button
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  isDarija ? 'فيلتر' : 'Filtres',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Add product button
          GestureDetector(
            onTap: () => context.go('/supplier/product/add'),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    isDarija ? 'زيد' : 'Ajouter',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Category filter tabs matching Screen F design.
  Widget _buildWebFilterTabs(bool isDarija) {
    final categories = [
      isDarija ? 'الكل' : 'Tout',
      isDarija ? 'شاشات' : 'Écrans',
      isDarija ? 'إكسسوارات' : 'Accessoires',
      isDarija ? 'شارجورات' : 'Chargeurs',
      isDarija ? 'كوابل' : 'Câbles',
      isDarija ? 'حماية' : 'Protection',
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.webCardBorder)),
      ),
      child: Row(
        children: categories.map((cat) {
          final isFirst = cat == categories.first;
          final isActive = _brandFilter == null ? isFirst : cat == _brandFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _brandFilter = isFirst ? null : cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentOrange.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.accentOrange : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Table header row matching Screen F design.
  Widget _buildWebTableHeader(bool isDarija) {
    return Container(
      height: 40,
      color: AppColors.webTableHeader,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Checkbox column
          SizedBox(
            width: 40,
            child: Checkbox(
              value: _isSelecting && _selectedIds.isNotEmpty,
              tristate: true,
              onChanged: (_) {
                if (!_isSelecting) _toggleSelectMode();
                final products = ref.read(supplierProductsProvider).valueOrNull ?? [];
                _selectAll(_applyFilters(products));
              },
              activeColor: AppColors.webIndigoLight,
              side: const BorderSide(color: AppColors.textTertiary),
            ),
          ),
          // Product name
          SizedBox(
            width: 260,
            child: Text(
              isDarija ? 'المنتوج' : 'Produit',
              style: _headerStyle,
            ),
          ),
          // Brand
          SizedBox(
            width: 120,
            child: Text(isDarija ? 'الماركة' : 'Marque', style: _headerStyle),
          ),
          // Stock
          SizedBox(
            width: 80,
            child: Text(isDarija ? 'المخزون' : 'Stock', style: _headerStyle, textAlign: TextAlign.center),
          ),
          // Price T1
          SizedBox(
            width: 110,
            child: Text(isDarija ? 'ثمن T1' : 'Prix T1', style: _headerStyle, textAlign: TextAlign.right),
          ),
          // Price T2
          SizedBox(
            width: 110,
            child: Text(isDarija ? 'ثمن T2' : 'Prix T2', style: _headerStyle, textAlign: TextAlign.right),
          ),
          // Status
          Expanded(
            child: Text(isDarija ? 'الحالة' : 'Statut', style: _headerStyle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  /// Single table row matching Screen F design.
  Widget _buildWebTableRow(Product product, bool isDarija) {
    final isSelected = _selectedIds.contains(product.id);
    final isLowStock = product.stockQuantity < 10;
    final tiers = product.sortedTiers;
    final t1Price = tiers.isNotEmpty ? (tiers.first.value as num).toDouble() : product.basePrice;
    final t2Price = tiers.length > 1 ? (tiers[1].value as num).toDouble() : null;

    return GestureDetector(
      onTap: _isSelecting
          ? () => _toggleSelected(product.id)
          : () => context.go('/supplier/product/${product.id}/edit', extra: product),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : AppColors.webCardBg,
          border: const Border(bottom: BorderSide(color: AppColors.webCardBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 40,
              child: GestureDetector(
                onTap: () {
                  if (!_isSelecting) _toggleSelectMode();
                  _toggleSelected(product.id);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.webIndigoLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.webIndigoLight : AppColors.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ),
            // Product name + icon + ref
            SizedBox(
              width: 260,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                      image: product.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: product.imageUrl == null
                        ? const Icon(Icons.inventory_2_outlined,
                            size: 16, color: AppColors.textTertiary)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          product.id.length >= 8
                              ? 'REF-${product.id.substring(0, 8).toUpperCase()}'
                              : 'REF-${product.id.toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Brand
            SizedBox(
              width: 120,
              child: Text(
                product.brand ?? '—',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Stock
            SizedBox(
              width: 80,
              child: Text(
                '${product.stockQuantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLowStock ? AppColors.alertRed : AppColors.textPrimary,
                ),
              ),
            ),
            // Price T1
            SizedBox(
              width: 110,
              child: Text(
                Formatters.price(t1Price),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Price T2
            SizedBox(
              width: 110,
              child: Text(
                t2Price != null ? Formatters.price(t2Price) : '—',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Status
            Expanded(
              child: Center(
                child: isLowStock
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isDarija ? 'مخزون ضعيف' : 'Stock faible',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isActive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF5F5F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.isActive
                              ? (isDarija ? 'نشيط' : 'Actif')
                              : (isDarija ? 'مخبي' : 'Masqué'),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.isActive
                                ? AppColors.successGreen
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating bulk action bar — indigo bar at bottom (Screen F).
  /// UI&UX.pen node: LlV2T
  Widget _buildWebBulkBar(bool isDarija) {
    return Container(
      width: 500,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.webIndigo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} ${isDarija ? 'مختارين' : 'articles sélectionnés'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // Bulk price update
          GestureDetector(
            onTap: () => _openBulkPriceModal(isDarija),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isDarija ? 'بدل الثمن' : 'Mise à jour Prix',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Deactivate
          GestureDetector(
            onTap: () {
              // TODO: bulk deactivate selected products
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isDarija ? 'خبّي' : 'Désactiver',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Close
          GestureDetector(
            onTap: _toggleSelectMode,
            child: const Icon(Icons.close, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDarija) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back,
                    size: 20, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDarija ? 'المنتوجات ديالي' : 'Mon inventaire',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isDarija ? 'Mon inventaire' : 'المنتوجات ديالي',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Multi-select toggle
          GestureDetector(
            onTap: _toggleSelectMode,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isSelecting
                    ? AppColors.accentOrange.withOpacity(0.15)
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  _isSelecting ? Icons.close : Icons.checklist,
                  size: 20,
                  color: _isSelecting
                      ? AppColors.accentOrange
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(bool isDarija) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: isDarija ? 'قلّب على منتوج...' : 'Rechercher...',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Icon(Icons.search,
                size: 20, color: AppColors.textTertiary),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BRAND FILTER CHIPS
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildBrandChips(bool isDarija) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        children: [
          // "All" chip
          _buildChip(
            label: isDarija ? 'الكل' : 'Tous',
            selected: _brandFilter == null,
            onTap: () => setState(() => _brandFilter = null),
          ),
          const SizedBox(width: 6),
          // Brand chips
          ...kBrands
              .where((b) => b != 'Autre')
              .take(8) // show top 8 inline
              .map((brand) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildChip(
                label: brand,
                selected: _brandFilter == brand,
                onTap: () => setState(() {
                  _brandFilter = _brandFilter == brand ? null : brand;
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.accentOrange : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color:
                selected ? AppColors.onAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SELECTION TOOLBAR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSelectionToolbar(bool isDarija) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIds.length} ${isDarija ? 'مختارين' : 'sélectionnés'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.accentOrange,
            ),
          ),
          const Spacer(),
          // Select all
          GestureDetector(
            onTap: () {
              final products =
                  ref.read(supplierProductsProvider).valueOrNull ?? [];
              _selectAll(_applyFilters(products));
            },
            child: Text(
              isDarija ? 'الكل' : 'Tout',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bulk price
          GestureDetector(
            onTap: _selectedIds.isEmpty
                ? null
                : () => _openBulkPriceModal(isDarija),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedIds.isEmpty
                    ? AppColors.bgMuted
                    : AppColors.accentOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune,
                      size: 16,
                      color: _selectedIds.isEmpty
                          ? AppColors.textTertiary
                          : Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    isDarija ? 'بدل الثمن' : 'Ajuster prix',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedIds.isEmpty
                          ? AppColors.textTertiary
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBulkPriceModal(bool isDarija) {
    final products =
        ref.read(supplierProductsProvider).valueOrNull ?? [];
    final selected =
        products.where((p) => _selectedIds.contains(p.id)).toList();
    if (selected.isEmpty) return;

    BulkPriceAdjustmentModal.show(
      context,
      products: selected,
      isDarija: isDarija,
      onApplied: () {
        ref.invalidate(supplierProductsProvider);
        setState(() {
          _isSelecting = false;
          _selectedIds.clear();
        });
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PRODUCT CARD
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildProductCard(Product product, bool isDarija) {
    final isSelected = _selectedIds.contains(product.id);

    return GestureDetector(
      onTap: _isSelecting
          ? () => _toggleSelected(product.id)
          : () => context.go('/supplier/product/${product.id}/edit',
                extra: product),
      onLongPress:
          _isSelecting ? null : () {
            _toggleSelectMode();
            _toggleSelected(product.id);
          },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.accentOrange, width: 2)
              : Border.all(color: AppColors.borderSubtle, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox (in selection mode)
            if (_isSelecting)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentOrange
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentOrange
                          : AppColors.bgMuted,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ),

            // Product image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                image: product.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product.imageUrl == null
                  ? const Center(
                      child: Icon(Icons.inventory_2_outlined,
                          size: 28, color: AppColors.textTertiary),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (product.isNew)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppColors.successGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDarija ? 'جديد' : 'Nouveau',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.successGreen,
                            ),
                          ),
                        ),
                      if (!product.isActive)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDarija ? 'مخبي' : 'Masqué',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.alertRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Brand + compatibility count
                  Row(
                    children: [
                      if (product.brand != null) ...[
                        Text(
                          product.brand!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (product.compatibilityList.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '📱 ${product.compatibilityList.length}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price + stock
                  Row(
                    children: [
                      // Base price
                      Text(
                        Formatters.price(product.basePrice),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      // Tier count
                      if (product.sortedTiers.length > 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.sortedTiers.length} ${isDarija ? 'باليات' : 'paliers'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Stock
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.successGreen.withOpacity(0.1)
                              : AppColors.alertRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.stockQuantity} ${isDarija ? 'فالمخزن' : 'en stock'}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.inStock
                                ? AppColors.successGreen
                                : AppColors.alertRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Toggle active (not in selection mode)
            if (!_isSelecting)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final updated = product.copyWith(
                          isActive: !product.isActive);
                      final repo = ref.read(productRepositoryProvider);
                      await repo.update(updated);
                      ref.invalidate(supplierProductsProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  child: Icon(
                    product.isActive
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                    color: product.isActive
                        ? AppColors.successGreen
                        : AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(bool isDarija, bool isEmpty) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmpty ? Icons.inventory_2_outlined : Icons.search_off,
            size: 56,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            isEmpty
                ? (isDarija
                    ? 'مازال ما عندك تا منتوج'
                    : 'Aucun produit encore')
                : (isDarija
                    ? 'ما لقينا والو'
                    : 'Aucun résultat'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEmpty
                ? (isDarija
                    ? 'كليكي على + باش تزيد منتوج'
                    : 'Cliquez sur + pour ajouter')
                : (isDarija
                    ? 'بدل الفيلتر ولا البحث'
                    : 'Modifiez le filtre ou la recherche'),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
