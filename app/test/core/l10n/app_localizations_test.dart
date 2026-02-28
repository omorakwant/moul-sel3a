import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/core/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations — French locale', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = AppLocalizations(const Locale('fr'));
    });

    test('appTitle returns French title', () {
      expect(l10n.appTitle, isNotEmpty);
    });

    test('confirmOrder returns French string', () {
      expect(l10n.confirmOrder, isNotEmpty);
    });

    test('formatPrice formats with DH suffix', () {
      final result = l10n.formatPrice(1234.5);
      expect(result, contains('DH'));
      expect(result, contains('1234'));
    });

    test('statusLabel maps known statuses', () {
      // Common order statuses
      final pending = l10n.statusLabel('pending');
      expect(pending, isNotEmpty);

      final delivered = l10n.statusLabel('delivered');
      expect(delivered, isNotEmpty);
    });

    test('statusLabel returns key for unknown status', () {
      final unknown = l10n.statusLabel('nonexistent_status');
      expect(unknown, 'nonexistent_status');
    });
  });

  group('AppLocalizations — Darija (ar) locale', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = AppLocalizations(const Locale('ar', 'MA'));
    });

    test('appTitle returns Darija title', () {
      expect(l10n.appTitle, isNotEmpty);
    });

    test('confirmOrder returns Darija string', () {
      expect(l10n.confirmOrder, isNotEmpty);
    });

    test('formatPrice includes DH', () {
      final result = l10n.formatPrice(500.0);
      expect(result, contains('DH'));
    });
  });

  group('AppLocalizations — supportedLocales', () {
    test('supports French and Arabic', () {
      final locales = AppLocalizations.supportedLocales;
      expect(locales.length, greaterThanOrEqualTo(2));

      final hasFrench = locales.any((l) => l.languageCode == 'fr');
      final hasArabic = locales.any((l) => l.languageCode == 'ar');
      expect(hasFrench, isTrue);
      expect(hasArabic, isTrue);
    });
  });

  group('AppLocalizations — localizationsDelegates', () {
    test('delegates list is not empty', () {
      expect(AppLocalizations.localizationsDelegates, isNotEmpty);
    });
  });
}
