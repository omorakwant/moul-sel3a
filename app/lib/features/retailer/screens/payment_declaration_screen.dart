import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../data/models/supplier_retailer_relation.dart';
import '../../../data/repositories/relation_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../providers/payment_providers.dart';

/// Payment Declaration Screen — the money engine UI.
///
/// PROJECT_CONTEXT.md — Payment Declaration Flow:
///   Step 1: Select payment service (Wafacash, CashPlus, Bank, Cash)
///   Step 2: Photo of receipt (camera)
///   Step 3: Manual entry (reference code + amount)
///   Step 4: Submit → ledger_transaction (status: pending)
///   Step 5: WhatsApp notification to supplier
class PaymentDeclarationScreen extends ConsumerStatefulWidget {
  final String relationId;

  const PaymentDeclarationScreen({
    super.key,
    required this.relationId,
  });

  @override
  ConsumerState<PaymentDeclarationScreen> createState() =>
      _PaymentDeclarationScreenState();
}

class _PaymentDeclarationScreenState
    extends ConsumerState<PaymentDeclarationScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedMethod = 'wafacash';
  File? _receiptPhoto;
  bool _isSubmitting = false;

  static const _paymentMethods = [
    {'key': 'wafacash', 'label': 'Wafacash', 'icon': Icons.account_balance},
    {'key': 'cashplus', 'label': 'CashPlus', 'icon': Icons.point_of_sale},
    {'key': 'bank_transfer', 'label': 'Virement', 'icon': Icons.account_balance_outlined},
    {'key': 'driver_cash', 'label': 'Cash', 'icon': Icons.payments_outlined},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _receiptPhoto = File(picked.path));
    }
  }

  Future<String?> _uploadReceipt(File file) async {
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final ext = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = '$userId/receipts/$fileName';

      await client.storage
          .from(SupabaseConstants.storageBucket)
          .upload(storagePath, file);

      return client.storage
          .from(SupabaseConstants.storageBucket)
          .getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('Receipt upload error: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload receipt photo if present
      String? evidenceUrl;
      if (_receiptPhoto != null) {
        evidenceUrl = await _uploadReceipt(_receiptPhoto!);
      }

      final amount = double.parse(_amountController.text.trim());
      final referenceCode = _referenceController.text.trim();

      await ref.read(declarePaymentProvider({
        'relation_id': widget.relationId,
        'amount': amount,
        'payment_method': _selectedMethod,
        'evidence_url': evidenceUrl,
        'reference_code': referenceCode.isNotEmpty ? referenceCode : null,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      }).future);

      if (mounted) {
        _showSuccessDialog(amount, referenceCode);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(double amount, String referenceCode) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.badgeDeliveredBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  size: 40, color: AppColors.successGreen),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.isDarija ? 'تصيفطات بنجاح!' : 'Déclaration envoyée !',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.price(amount),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.isDarija
                  ? 'الحساب غادي يتحدث ملي المولي يأكد'
                  : 'Le solde sera mis à jour après validation du fournisseur',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            // WhatsApp notify button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  // Fetch supplier phone from relation
                  final relation = await ref
                      .read(relationRepositoryProvider)
                      .getById(widget.relationId);
                  final phone = relation?.supplierPhone;
                  if (phone != null && phone.isNotEmpty) {
                    final message = l10n.isDarija
                        ? 'السلام عليكم، صيفطت ليك الخلصة: ${Formatters.price(amount)}\nالرقم السري: $referenceCode\nالطريقة: $_selectedMethod\nعافاك أكد ف التطبيق 🙏'
                        : 'Bonjour, j\'ai déclaré un paiement de ${Formatters.price(amount)}\nRéf: $referenceCode\nMéthode: $_selectedMethod\nMerci de valider dans l\'application.';
                    final url = Uri.parse(Formatters.whatsappLink(
                      phone: phone,
                      message: message,
                    ));
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) context.pop();
                },
                icon: const Icon(Icons.chat, size: 18),
                label: Text(l10n.isDarija
                    ? 'صيفط للمولي فواتساب'
                    : 'Notifier le grossiste (WhatsApp)'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: Text(
                l10n.isDarija ? 'رجع' : 'Retour',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final relationAsync = ref.watch(
      FutureProvider.autoDispose<SupplierRetailerRelation?>((ref) async {
        final repo = ref.watch(relationRepositoryProvider);
        return repo.getById(widget.relationId);
      }),
    );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.declarePayment,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            relationAsync.when(
              data: (r) => r != null
                  ? Text(
                      '${r.supplierName ?? ""} · ${l10n.currentDebt}: ${Formatters.price(r.currentBalance)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step 1: Payment Method Selection ──
              _SectionLabel(
                label: l10n.isDarija ? 'اختار الطريقة' : 'Mode de paiement',
                icon: Icons.payment,
              ),
              const SizedBox(height: 12),
              _buildMethodSelector(),

              const SizedBox(height: 28),

              // ── Step 2: Receipt Photo ──
              _SectionLabel(
                label: l10n.uploadReceipt,
                icon: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 12),
              _buildReceiptCapture(l10n),

              const SizedBox(height: 28),

              // ── Step 3: Manual Data Entry ──
              _SectionLabel(
                label: l10n.isDarija ? 'المعلومات' : 'Informations',
                icon: Icons.edit_note,
              ),
              const SizedBox(height: 12),

              // Reference Code
              TextFormField(
                controller: _referenceController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: l10n.isDarija ? 'الرقم السري' : 'Code de transaction',
                  hintText: l10n.isDarija ? 'الرقم لي فالورقة' : 'Réf. sur le reçu',
                  prefixIcon: const Icon(Icons.tag, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.accentOrange, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.isDarija ? 'شحال صيفطتي' : 'Montant versé',
                  hintText: '0.00',
                  suffixText: 'DH',
                  prefixIcon: const Icon(Icons.attach_money, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.accentOrange, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.isDarija ? 'دخل المبلغ' : 'Montant requis';
                  }
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) {
                    return l10n.isDarija ? 'مبلغ غير صحيح' : 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes (optional)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.isDarija ? 'ملاحظات (اختياري)' : 'Notes (optionnel)',
                  prefixIcon: const Icon(Icons.notes, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.accentOrange, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Step 4: Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                  label: Text(
                    l10n.isDarija
                        ? 'صيفط لمول السلعة'
                        : 'Envoyer au Grossiste',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.isDarija
                      ? 'الحساب غادي يتحدث ملي المولي يأكد'
                      : 'Le solde sera mis à jour après validation du fournisseur',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _paymentMethods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final method = _paymentMethods[index];
          final key = method['key'] as String;
          final label = method['label'] as String;
          final icon = method['icon'] as IconData;
          final isSelected = _selectedMethod == key;

          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 85,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentOrange.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentOrange
                      : AppColors.borderSubtle,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? AppColors.accentOrange
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.accentOrange
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceiptCapture(AppLocalizations l10n) {
    if (_receiptPhoto != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              _receiptPhoto!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _receiptPhoto = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.alertRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: _pickReceiptPhoto,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      l10n.isDarija ? 'بدل' : 'Reprendre',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickReceiptPhoto,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(
              l10n.isDarija ? 'صور الورقة' : 'Prendre une photo du reçu',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.isDarija
                  ? 'خلي الرقم السري بان مزيان'
                  : 'Assurez-vous que le numéro de réf. est visible',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accentOrange),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
