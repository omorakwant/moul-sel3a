/// App-wide constants following PROJECT_CONTEXT.md rules.
class AppConstants {
  AppConstants._();

  // ── Currency ──
  static const String currencyCode = 'DH';
  static const String currencyLocale = 'fr_MA';

  // ── Date Format ──
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ── User Roles ──
  static const String roleSupplier = 'supplier';
  static const String roleRetailer = 'retailer';
  static const String roleDriver = 'driver';

  // ── Order Statuses ──
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderReadyForPickup = 'ready_for_pickup';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // ── Ledger Transaction Types ──
  static const String txOrderIncrease = 'order_increase';
  static const String txPaymentDecrease = 'payment_decrease';

  // ── Ledger Statuses ──
  static const String txPending = 'pending';
  static const String txVerified = 'verified';
  static const String txRejected = 'rejected';

  // ── Delivery Job Types ──
  static const String jobDeliveryOnly = 'delivery_only';
  static const String jobCOD = 'cod';

  // ── Payment Methods ──
  // Per PROJECT_CONTEXT.md payment declaration spec:
  //   Wafacash, CashPlus, Bank Transfer, Driver Cash (+ check for legacy)
  static const List<String> paymentMethods = [
    'wafacash',
    'cashplus',
    'bank_transfer',
    'driver_cash',
    'check',
  ];

  // ── WhatsApp ──
  static const String whatsappBaseUrl = 'https://wa.me/';
}
