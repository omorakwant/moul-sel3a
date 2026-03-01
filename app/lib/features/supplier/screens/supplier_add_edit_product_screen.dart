import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/errors/error_widgets.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../providers/supplier_inventory_providers.dart';

/// Add / Edit Product Screen — Supplier Inventory Management.
///
/// PROJECT_CONTEXT.md — Step 5 "Inventory (Quick Add)":
///   "A tabular view to add products rapidly. Inputs: Name, Price tiers (JSON), and Image."
///
/// Fields:
///   1. Product Name (required)
///   2. Brand (select from kBrands)
///   3. Phone Model Compatibility (multi-select from kPhoneModels)
///   4. Tiered Pricing (dynamic tier rows: qty threshold → price in DH)
///   5. Stock Quantity
///   6. Product Image (Supabase Storage upload)
///   7. "Nouveau / جديد" toggle
class SupplierAddEditProductScreen extends ConsumerStatefulWidget {
  /// If non-null, editing an existing product.
  final Product? existingProduct;

  const SupplierAddEditProductScreen({
    super.key,
    this.existingProduct,
  });

  @override
  ConsumerState<SupplierAddEditProductScreen> createState() =>
      _SupplierAddEditProductScreenState();
}

class _SupplierAddEditProductScreenState
    extends ConsumerState<SupplierAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _stockController;
  String? _selectedBrand;
  final Set<String> _selectedModels = {};
  bool _isNew = true;
  bool _isSubmitting = false;
  String? _imageUrl;
  File? _pickedImageFile;

  /// Dynamic tier rows: [{qty: TextEditingController, price: TextEditingController}]
  final List<_TierRow> _tierRows = [];

  bool get _isDarija => ref.watch(localeProvider) == 'ar';
  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _stockController =
        TextEditingController(text: (p?.stockQuantity ?? 0).toString());
    _selectedBrand = p?.brand;
    if (p != null) {
      _selectedModels.addAll(p.compatibilityList);
      _isNew = p.isNew;
      _imageUrl = p.imageUrl;

      // Populate tier rows from existing price_tiers
      for (final entry in p.sortedTiers) {
        _tierRows.add(_TierRow(
          qtyController: TextEditingController(text: entry.key.toString()),
          priceController:
              TextEditingController(text: entry.value.toStringAsFixed(2)),
        ));
      }
    }

    // Ensure at least one tier row
    if (_tierRows.isEmpty) {
      _tierRows.add(_TierRow(
        qtyController: TextEditingController(text: '1'),
        priceController: TextEditingController(),
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    for (final row in _tierRows) {
      row.qtyController.dispose();
      row.priceController.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _buildPriceTiers() {
    final tiers = <String, dynamic>{};
    for (final row in _tierRows) {
      final qty = row.qtyController.text.trim();
      final price = double.tryParse(row.priceController.text.trim());
      if (qty.isNotEmpty && price != null) {
        tiers[qty] = price;
      }
    }
    return tiers;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final tiers = _buildPriceTiers();
    if (tiers.isEmpty) {
      _showSnackBar(_isDarija
          ? 'خاصك تدخل واحد الثمن على الأقل'
          : 'Veuillez ajouter au moins un palier de prix');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload image if picked
      String? imageUrl = _imageUrl;
      if (_pickedImageFile != null) {
        final storage = ref.read(storageServiceProvider);
        imageUrl = await storage.uploadProductImage(_pickedImageFile!);
      }

      if (_isEditing) {
        final updated = widget.existingProduct!.copyWith(
          name: _nameController.text.trim(),
          brand: _selectedBrand,
          imageUrl: imageUrl,
          compatibilityList: _selectedModels.toList(),
          priceTiers: tiers,
          isNew: _isNew,
          stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
        );
        final repo = ref.read(productRepositoryProvider);
        await repo.update(updated);
      } else {
        final data = {
          'name': _nameController.text.trim(),
          'brand': _selectedBrand,
          'image_url': imageUrl,
          'compatibility_list': _selectedModels.toList(),
          'price_tiers': tiers,
          'is_new': _isNew,
          'stock_quantity': int.tryParse(_stockController.text.trim()) ?? 0,
        };
        await ref.read(createProductProvider(data).future);
      }

      ref.invalidate(supplierProductsProvider);

      if (mounted) {
        _showSnackBar(_isDarija ? 'مزيان!' : 'Produit enregistré');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDarija = _isDarija;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(isDarija),

            // ── Form ──
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  children: [
                    // 1. Product Image
                    _buildImagePicker(isDarija),
                    const SizedBox(height: 20),

                    // 2. Product Name
                    _buildSectionLabel(
                      isDarija ? 'اسم المنتوج' : 'Nom du produit',
                      isDarija ? 'Nom du produit' : 'اسم المنتوج',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _nameController,
                      hint: isDarija
                          ? 'مثلا: كابل USB-C'
                          : 'ex: Câble USB-C',
                      icon: Icons.inventory_2_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return isDarija
                              ? 'دخل اسم المنتوج'
                              : 'Nom requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // 3. Brand Select
                    _buildSectionLabel(
                      isDarija ? 'الماركة' : 'Marque',
                      isDarija ? 'Marque' : 'الماركة',
                    ),
                    const SizedBox(height: 6),
                    _buildBrandSelector(isDarija),
                    const SizedBox(height: 18),

                    // 4. Compatibility Multi-Select
                    _buildSectionLabel(
                      isDarija ? 'الموديلات المتوافقة' : 'Compatibilité Modèles',
                      isDarija ? 'Compatibilité' : 'التوافق',
                    ),
                    const SizedBox(height: 6),
                    _buildCompatibilitySelector(isDarija),
                    const SizedBox(height: 18),

                    // 5. Tiered Pricing
                    _buildSectionLabel(
                      isDarija ? 'ثمن الجملة' : 'Prix de Gros',
                      isDarija ? 'Prix de Gros (paliers)' : 'الأثمنة بالجملة',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDarija
                          ? 'مثلا: 1-10 قطع = 50 DH، 11-50 قطع = 45 DH'
                          : 'ex: 1-10 pcs = 50 DH, 11-50 pcs = 45 DH',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTierEditor(isDarija),
                    const SizedBox(height: 18),

                    // 6. Stock Quantity
                    _buildSectionLabel(
                      isDarija ? 'الكمية فالمخزن' : 'Quantité en stock',
                      isDarija ? 'Stock' : 'المخزن',
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _stockController,
                      hint: '0',
                      icon: Icons.warehouse_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 18),

                    // 7. "Nouveau / جديد" Toggle
                    _buildNewArrivalToggle(isDarija),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── FAB: Save ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSubmitting ? null : _submit,
        backgroundColor: AppColors.accentOrange,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check, color: Colors.white),
        label: Text(
          _isEditing
              ? (isDarija ? 'حفظ التعديل' : 'Enregistrer')
              : (isDarija ? 'زيد المنتوج' : 'Ajouter'),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDarija) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  _isEditing
                      ? (isDarija ? 'بدل المنتوج' : 'Modifier le produit')
                      : (isDarija ? 'منتوج جديد' : 'Nouveau produit'),
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isEditing
                      ? (isDarija ? 'Modifier le produit' : 'بدل المنتوج')
                      : (isDarija ? 'Nouveau produit' : 'منتوج جديد'),
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
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // IMAGE PICKER
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildImagePicker(bool isDarija) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1,
            style: BorderStyle.solid,
          ),
          image: _pickedImageFile != null
              ? DecorationImage(
                  image: FileImage(_pickedImageFile!),
                  fit: BoxFit.cover,
                )
              : (_imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null),
        ),
        child: (_pickedImageFile == null && _imageUrl == null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 36, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text(
                    isDarija ? 'صور المنتوج' : 'Photo du produit',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    isDarija ? 'Photo du produit' : 'صور المنتوج',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit,
                      size: 16, color: Colors.white),
                ),
              ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BRAND SELECTOR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildBrandSelector(bool isDarija) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedBrand,
          hint: Text(
            isDarija ? 'اختار الماركة' : 'Choisir la marque',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
          ),
          items: kBrands.map((b) {
            return DropdownMenuItem(
              value: b,
              child: Text(b,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  )),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedBrand = v),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // COMPATIBILITY MULTI-SELECT
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildCompatibilitySelector(bool isDarija) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected chips
        if (_selectedModels.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedModels.map((model) {
              return Chip(
                label: Text(model,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onAccent,
                    )),
                backgroundColor: AppColors.accentOrange,
                deleteIconColor: AppColors.onAccent,
                onDeleted: () =>
                    setState(() => _selectedModels.remove(model)),
              );
            }).toList(),
          ),
        if (_selectedModels.isNotEmpty) const SizedBox(height: 8),

        // "Add model" button
        GestureDetector(
          onTap: () => _showModelPicker(isDarija),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.add,
                    size: 20, color: AppColors.accentOrange),
                const SizedBox(width: 8),
                Text(
                  isDarija
                      ? 'زيد موديل (${_selectedModels.length})'
                      : 'Ajouter un modèle (${_selectedModels.length})',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showModelPicker(bool isDarija) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (ctx, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
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
                      Text(
                        isDarija
                            ? 'اختار الموديلات'
                            : 'Sélectionner les modèles',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: kPhoneModels.length,
                          itemBuilder: (ctx, i) {
                            final model = kPhoneModels[i];
                            final selected =
                                _selectedModels.contains(model);
                            return CheckboxListTile(
                              value: selected,
                              activeColor: AppColors.accentOrange,
                              title: Text(model,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                  )),
                              onChanged: (v) {
                                setModalState(() {
                                  if (v == true) {
                                    _selectedModels.add(model);
                                  } else {
                                    _selectedModels.remove(model);
                                  }
                                });
                                setState(() {}); // update parent
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            isDarija
                                ? 'تم (${_selectedModels.length})'
                                : 'Valider (${_selectedModels.length})',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TIERED PRICING EDITOR
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTierEditor(bool isDarija) {
    return Column(
      children: [
        // Tier rows
        ...List.generate(_tierRows.length, (i) {
          final row = _tierRows[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // Tier number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Quantity threshold
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: row.qtyController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: isDarija ? 'من' : 'À partir de',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        suffixText: isDarija ? 'قطعة' : 'pcs',
                        suffixStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow icon
                const Icon(Icons.arrow_forward,
                    size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),

                // Price in DH
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: row.priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                        suffixText: 'DH',
                        suffixStyle: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentOrange,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),

                // Remove tier button
                if (_tierRows.length > 1)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _tierRows[i].qtyController.dispose();
                        _tierRows[i].priceController.dispose();
                        _tierRows.removeAt(i);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.remove_circle_outline,
                          size: 22, color: AppColors.alertRed),
                    ),
                  ),
              ],
            ),
          );
        }),

        // Add tier button
        GestureDetector(
          onTap: () {
            setState(() {
              _tierRows.add(_TierRow(
                qtyController: TextEditingController(),
                priceController: TextEditingController(),
              ));
            });
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentOrange.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add,
                    size: 18, color: AppColors.accentOrange),
                const SizedBox(width: 6),
                Text(
                  isDarija ? 'زيد بالية جديدة' : 'Ajouter un palier',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // NEW ARRIVAL TOGGLE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildNewArrivalToggle(bool isDarija) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.fiber_new,
                  size: 20, color: AppColors.successGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDarija ? 'جديد' : 'Nouveauté',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isDarija
                      ? 'المنتوج غادي يبان فالأول'
                      : 'Apparaîtra en haut du catalogue',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isNew,
            activeTrackColor: AppColors.successGreen,
            onChanged: (v) => setState(() => _isNew = v),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHARED TEXT FIELD
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            color: AppColors.textTertiary,
          ),
          prefixIcon:
              Icon(icon, size: 20, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION LABEL — bilingual
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String primary, String secondary) {
    return Row(
      children: [
        Text(
          primary,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          secondary,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Helper class to manage tier row controllers.
class _TierRow {
  final TextEditingController qtyController;
  final TextEditingController priceController;

  _TierRow({
    required this.qtyController,
    required this.priceController,
  });
}
