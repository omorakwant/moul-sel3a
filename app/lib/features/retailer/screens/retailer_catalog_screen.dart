import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../providers/cart_providers.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';

/// Retailer Catalog Screen — "Screen 2 — Catalog" from UI&UX.pen.
///
/// Design spec (from `SHuND`):
///   Layout: vertical flex, clip: true, fill $bg-primary
///   Children:
///     1. statusBar (system)
///     2. contentWrapper: vertical flex, gap 16, padding [0,24,24,24]
///        a. header2: "Catalogue" title (Manrope 32/800) + supplier name (Inter 14/500, $accent-orange) + back button
///        b. searchInst: SearchBar component ref
///        c. brandFilters: horizontal flex, gap 8 — FilterChip/FilterChipActive refs
///        d. modelSelector: cornerRadius 12, fill $bg-surface, height 48 — dropdown
///        e. productGrid: 2-column grid of ProductCard refs, gap 12
///     3. tabBarSection: TabBar at bottom
///
/// Interactive features:
///   - Brand filter chips: tap to filter by brand (Apple, Samsung, Xiaomi…)
///   - Model selector: dropdown to filter by phone model compatibility
///   - Search bar: real-time text search by product name
///   - Product cards: quantity stepper with dynamic tiered pricing
class RetailerCatalogScreen extends ConsumerStatefulWidget {
  final String supplierId;
  final String? supplierName;
  final String? relationId;
  final String? supplierPhone;

  const RetailerCatalogScreen({
    super.key,
    required this.supplierId,
    this.supplierName,
    this.relationId,
    this.supplierPhone,
  });

  @override
  ConsumerState<RetailerCatalogScreen> createState() =>
      _RetailerCatalogScreenState();
}

class _RetailerCatalogScreenState
    extends ConsumerState<RetailerCatalogScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    // Set the supplier ID and relation ID for all catalog providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(catalogSupplierIdProvider.notifier).state =
          widget.supplierId;
      if (widget.relationId != null) {
        ref.read(catalogRelationIdProvider.notifier).state =
            widget.relationId;
      }
    });
    // Initialize speech engine once
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VOICE SEARCH — Step 3 spec: "use speech_to_text package to capture
  //   Darija/French product names and auto-fill the text search field."
  // ═══════════════════════════════════════════════════════════════════════════
  void _startVoiceSearch() {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).isDarija
                ? 'الميكروفون ماخدامش'
                : 'Microphone non disponible',
          ),
          backgroundColor: AppColors.alertRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isListening = true);

    // Prefer French locale; falls back to default if unavailable.
    // Darija is generally recognised under 'ar' but most devices map it to
    // 'ar_MA' or generic 'ar'. French ('fr_FR') works well for product names
    // that are commonly in French/English (e.g. "coque iPhone 15").
    _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords;
        if (words.isNotEmpty) {
          _searchController.text = words;
          ref.read(catalogSearchQueryProvider.notifier).state = words;
        }
      },
      localeId: 'fr_FR',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.search,
        cancelOnError: true,
      ),
    );
  }

  void _stopVoiceSearch() {
    _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  /// Opens WhatsApp to send a voice note to the current supplier.
  /// PROJECT_CONTEXT.md: "Voice Notes: Integrated WhatsApp button on every
  /// order page for Darija-based communication."
  /// Pro-Tip tooltip label: "صيفط أوديو" (Send Audio)
  Future<void> _openWhatsAppVoiceNote() async {
    final phone = widget.supplierPhone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).isDarija
                ? 'ما كاينش رقم الهاتف ديال المول السلعة'
                : 'Numéro du fournisseur indisponible',
          ),
          backgroundColor: AppColors.alertRed,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final message = l10n.isDarija
        ? 'سلام، بغيت نصيفط ليك أوديو...'
        : 'Bonjour, je souhaite vous envoyer un vocal...';
    final url = Uri.parse(Formatters.whatsappLink(phone: phone, message: message));
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.isDarija
                ? 'ما قدرناش نفتحو واتساب'
                : 'Impossible d\'ouvrir WhatsApp'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    }
  }

  /// Navigate to cart screen with supplier context.
  void _navigateToCart(BuildContext context) {
    context.push(
      '/retailer/cart/${widget.supplierId}',
      extra: {
        'supplierName': widget.supplierName,
        'supplierPhone': widget.supplierPhone,
        'relationId': widget.relationId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(catalogProductsProvider);
    final brandsAsync = ref.watch(catalogBrandsProvider);
    final modelsAsync = ref.watch(catalogModelsProvider);
    final selectedBrand = ref.watch(selectedBrandProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    final cartCount = ref.watch(cartItemCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final relationAsync = ref.watch(catalogRelationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      // WhatsApp voice note FAB — only when cart is empty (sticky bar takes over)
      floatingActionButton: cartCount == 0
          ? FloatingActionButton(
              onPressed: _openWhatsAppVoiceNote,
              backgroundColor: const Color(0xFF25D366),
              tooltip: l10n.callWhatsApp,
              child: const Icon(Icons.mic, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable content ──
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ══════════════════════════════════════════════════════
                  // HEADER
                  // ══════════════════════════════════════════════════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildHeader(context, l10n),
                    ),
                  ),

                  // ══════════════════════════════════════════════════════
                  // SEARCH BAR
                  // ══════════════════════════════════════════════════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildSearchBar(l10n),
                    ),
                  ),

                  // ══════════════════════════════════════════════════════
                  // BRAND FILTER CHIPS
                  // ══════════════════════════════════════════════════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
                      child: _buildBrandFilters(
                        brandsAsync,
                        selectedBrand,
                      ),
                    ),
                  ),

                  // ══════════════════════════════════════════════════════
                  // MODEL SELECTOR DROPDOWN
                  // ══════════════════════════════════════════════════════
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildModelSelector(
                        l10n,
                        modelsAsync,
                        selectedModel,
                      ),
                    ),
                  ),

                  // ══════════════════════════════════════════════════════
                  // PRODUCT GRID
                  // ══════════════════════════════════════════════════════
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    sliver: _buildProductGrid(productsAsync, l10n),
                  ),
                ],
              ),
            ),

            // ── Sticky Bottom Bar (cart summary + credit limit) ──
            if (cartCount > 0)
              _buildStickyCartBar(context, l10n, cartCount, cartTotal, relationAsync),

            // ── Tab Bar ──
            _buildTabBar(context, l10n),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STICKY CART BAR — real-time cart total + credit limit guard
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStickyCartBar(
    BuildContext context,
    AppLocalizations l10n,
    int cartCount,
    double cartTotal,
    AsyncValue<dynamic> relationAsync,
  ) {
    // Extract credit info from relation
    double? creditLimit;
    double currentBalance = 0;
    relationAsync.whenData((relation) {
      if (relation != null) {
        creditLimit = relation.creditLimit;
        currentBalance = relation.currentBalance;
      }
    });

    // Check if this order would exceed credit limit
    final projectedBalance = currentBalance + cartTotal;
    final bool isOverLimit =
        creditLimit != null && creditLimit! > 0 && projectedBalance > creditLimit!;
    final double remainingCredit =
        creditLimit != null && creditLimit! > 0 ? creditLimit! - currentBalance : 0;

    return Container(
      decoration: BoxDecoration(
        color: isOverLimit
            ? AppColors.alertRed.withValues(alpha: 0.05)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isOverLimit ? AppColors.alertRed.withValues(alpha: 0.3) : AppColors.bgSurface,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Over-limit warning banner ──
          if (isOverLimit)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: AppColors.alertRed.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.alertRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.overCreditLimit,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                // ── Left: item count + total ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cartCount ${l10n.items} ${l10n.isDarija ? "فلياني" : "dans le panier"}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            l10n.estimatedTotal,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.price(cartTotal),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isOverLimit
                                  ? AppColors.alertRed
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Credit remaining hint
                      if (creditLimit != null && creditLimit! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${l10n.remainingCredit}: ${Formatters.price(remainingCredit)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: isOverLimit
                                  ? AppColors.alertRed
                                  : AppColors.successGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Right: View Cart button ──
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToCart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: AppColors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                    label: Text(
                      l10n.viewCart,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER — "Catalogue" + supplier name + back button
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title + supplier name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Catalogue" — Manrope 32/800
              Text(
                l10n.isDarija ? 'كاتالوغ' : 'Catalogue',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              // Supplier name — Inter 14/500, $accent-orange
              if (widget.supplierName != null)
                Text(
                  widget.supplierName!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentOrange,
                  ),
                ),
            ],
          ),
        ),

        // Back button — cornerRadius 12, fill $bg-surface, 48x48
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SEARCH BAR — matches Component/SearchBar from UI&UX.pen
  //   cornerRadius 14, fill $bg-surface, height 52, gap 14, padding [0,18]
  //   [search icon] [text field] [mic icon]
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                ref.read(catalogSearchQueryProvider.notifier).state =
                    value.trim();
              },
              decoration: InputDecoration(
                hintText: l10n.isDarija
                    ? 'قلب بالموديل...'
                    : 'Rechercher par modèle...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onLongPress: _startVoiceSearch,
            onLongPressUp: _stopVoiceSearch,
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 20,
              color: _isListening
                  ? AppColors.alertRed
                  : AppColors.accentOrange,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BRAND FILTER CHIPS — horizontal scrollable row
  //   Active: cornerRadius 100, fill $bg-dark, text $text-on-dark (Manrope 13/600)
  //   Inactive: cornerRadius 100, fill $bg-surface, text $text-secondary (Manrope 13/600)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildBrandFilters(
    AsyncValue<List<String>> brandsAsync,
    String? selectedBrand,
  ) {
    return SizedBox(
      height: 40,
      child: brandsAsync.when(
        data: (brands) {
          if (brands.isEmpty) return const SizedBox.shrink();

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 24),
            itemCount: brands.length + 1, // +1 for "All" chip
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" chip — show all brands
                final isActive = selectedBrand == null;
                return _buildFilterChip(
                  label: 'Tout',
                  isActive: isActive,
                  onTap: () {
                    ref.read(selectedBrandProvider.notifier).state = null;
                  },
                );
              }

              final brand = brands[index - 1];
              final isActive = selectedBrand == brand;

              return _buildFilterChip(
                label: brand,
                isActive: isActive,
                onTap: () {
                  ref.read(selectedBrandProvider.notifier).state =
                      isActive ? null : brand;
                },
              );
            },
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  /// Single filter chip — matches FilterChip / FilterChipActive from UI&UX.pen.
  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgDark : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive
                ? AppColors.textOnDark
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // MODEL SELECTOR — dropdown for phone model compatibility filtering
  //   cornerRadius 12, fill $bg-surface, height 48, padding [0,16]
  //   [modelLabel (Manrope 14/600)] ─── [chevron-down]
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildModelSelector(
    AppLocalizations l10n,
    AsyncValue<List<String>> modelsAsync,
    String? selectedModel,
  ) {
    return GestureDetector(
      onTap: () => _showModelPicker(l10n, modelsAsync),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedModel ??
                  (l10n.isDarija
                      ? 'كل الموديلات'
                      : 'Tous les modèles'),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selectedModel != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showModelPicker(
    AppLocalizations l10n,
    AsyncValue<List<String>> modelsAsync,
  ) {
    modelsAsync.whenData((models) {
      if (models.isEmpty) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bgPrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.isDarija
                            ? 'ختار الموديل'
                            : 'Choisir le modèle',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(selectedModelProvider.notifier).state =
                              null;
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.isDarija ? 'كولشي' : 'Tous',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                // Model list
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: models.length,
                    itemBuilder: (context, index) {
                      final model = models[index];
                      final isSelected =
                          ref.read(selectedModelProvider) == model;

                      return ListTile(
                        title: Text(
                          model,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.accentOrange
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.accentOrange,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          ref.read(selectedModelProvider.notifier).state =
                              model;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PRODUCT GRID — 2-column grid of ProductCards, gap 12
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildProductGrid(
    AsyncValue<List<Product>> productsAsync,
    AppLocalizations l10n,
  ) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(l10n),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.52, // taller cards for tier hints + stepper
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: (product, quantity) {
                  ref.read(cartProvider.notifier).addItem(
                    product,
                    widget.supplierId,
                    quantity: quantity,
                  );
                  final l10n = AppLocalizations.of(context);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.addedToCart} — ${product.name} × $quantity',
                        style: const TextStyle(fontFamily: 'Inter'),
                      ),
                      backgroundColor: AppColors.successGreen,
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: l10n.viewCart,
                        textColor: Colors.white,
                        onPressed: () => _navigateToCart(context),
                      ),
                    ),
                  );
                },
              );
            },
            childCount: products.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: CircularProgressIndicator(
              color: AppColors.accentOrange,
            ),
          ),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.alertRed,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.error,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(catalogProductsProvider),
                  child: Text(
                    l10n.retry,
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.isDarija
                  ? 'ما كاينة حتى سلعة'
                  : 'Aucun produit trouvé',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.isDarija
                  ? 'بدل الفيلتر أولا قلب على شي حاجة خرى'
                  : 'Essayez un autre filtre ou recherche',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB BAR — matches Component/TabBar, "Catalogue" tab active
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Container(
        height: 62,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            _tabItem(
              icon: Icons.home,
              label: l10n.isDarija ? 'الرئيسية' : 'Accueil',
              isActive: false,
              onTap: () => context.goNamed('retailer-dashboard'),
            ),
            _tabItem(
              icon: Icons.grid_view_rounded,
              label: l10n.isDarija ? 'كاتالوغ' : 'Catalogue',
              isActive: true,
              onTap: () {},
            ),
            _tabItem(
              icon: Icons.description_outlined,
              label: l10n.isDarija ? 'البونات' : 'Bons',
              isActive: false,
              onTap: () => context.goNamed('retailer-orders'),
            ),
            _tabItem(
              icon: Icons.person_outline,
              label: l10n.isDarija ? 'بروفيل' : 'Profil',
              isActive: false,
              onTap: () => context.goNamed('retailer-profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? AppColors.accentOrange
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive
                    ? AppColors.accentOrange
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
