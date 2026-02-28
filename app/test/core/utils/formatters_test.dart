import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/core/utils/formatters.dart';

void main() {
  group('Formatters.price', () {
    test('formats with 2 decimal places and DH suffix', () {
      expect(Formatters.price(15.0), '15.00 DH');
      expect(Formatters.price(0.5), '0.50 DH');
      expect(Formatters.price(1234.567), '1234.57 DH');
    });

    test('formats zero correctly', () {
      expect(Formatters.price(0), '0.00 DH');
    });
  });

  group('Formatters.compactPrice', () {
    test('formats millions with M suffix', () {
      expect(Formatters.compactPrice(1200000), '1.2M DH');
      expect(Formatters.compactPrice(5000000), '5.0M DH');
    });

    test('formats thousands with k suffix', () {
      expect(Formatters.compactPrice(12500), '12.5k DH');
      expect(Formatters.compactPrice(1000), '1.0k DH');
    });

    test('formats below 1000 as normal price', () {
      expect(Formatters.compactPrice(999), '999.00 DH');
      expect(Formatters.compactPrice(50), '50.00 DH');
    });
  });

  group('Formatters.date', () {
    test('formats as DD/MM/YYYY', () {
      final dt = DateTime(2026, 2, 18);
      expect(Formatters.date(dt), '18/02/2026');
    });

    test('pads single-digit day and month', () {
      final dt = DateTime(2026, 1, 5);
      expect(Formatters.date(dt), '05/01/2026');
    });
  });

  group('Formatters.dateTime', () {
    test('formats as DD/MM/YYYY HH:mm', () {
      final dt = DateTime(2026, 12, 25, 14, 30);
      expect(Formatters.dateTime(dt), '25/12/2026 14:30');
    });
  });

  group('Formatters.timeOnly', () {
    test('formats as HH:mm', () {
      final dt = DateTime(2026, 1, 1, 9, 5);
      expect(Formatters.timeOnly(dt), '09:05');
    });

    test('handles midnight', () {
      final dt = DateTime(2026, 1, 1, 0, 0);
      expect(Formatters.timeOnly(dt), '00:00');
    });
  });

  group('Formatters.dateShort', () {
    test('formats as DD/MM without year', () {
      final dt = DateTime(2026, 3, 15);
      expect(Formatters.dateShort(dt), '15/03');
    });
  });

  group('Formatters.timeAgo', () {
    test('returns instant for < 1 minute', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 30));
      expect(Formatters.timeAgo(dt), 'à l\'instant');
    });

    test('returns minutes for < 60 minutes', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      expect(Formatters.timeAgo(dt), 'il y a 5min');
    });

    test('returns hours for < 24 hours', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(Formatters.timeAgo(dt), 'il y a 3h');
    });

    test('returns days for < 7 days', () {
      final dt = DateTime.now().subtract(const Duration(days: 2));
      expect(Formatters.timeAgo(dt), 'il y a 2j');
    });

    test('returns formatted date for >= 7 days', () {
      final dt = DateTime.now().subtract(const Duration(days: 10));
      // Should return DD/MM/YYYY format
      expect(Formatters.timeAgo(dt), contains('/'));
    });
  });

  group('Formatters.resolveTieredPrice', () {
    final tiers = {'1': 15.0, '10': 12.0, '50': 10.0};

    test('returns tier 1 price for qty < 10', () {
      expect(Formatters.resolveTieredPrice(tiers, 1), 15.0);
      expect(Formatters.resolveTieredPrice(tiers, 5), 15.0);
      expect(Formatters.resolveTieredPrice(tiers, 9), 15.0);
    });

    test('returns tier 2 price for qty 10-49', () {
      expect(Formatters.resolveTieredPrice(tiers, 10), 12.0);
      expect(Formatters.resolveTieredPrice(tiers, 25), 12.0);
      expect(Formatters.resolveTieredPrice(tiers, 49), 12.0);
    });

    test('returns tier 3 price for qty >= 50', () {
      expect(Formatters.resolveTieredPrice(tiers, 50), 10.0);
      expect(Formatters.resolveTieredPrice(tiers, 100), 10.0);
    });

    test('returns 0.0 for empty tiers', () {
      expect(Formatters.resolveTieredPrice({}, 5), 0.0);
    });

    test('handles single tier', () {
      expect(Formatters.resolveTieredPrice({'1': 20.0}, 100), 20.0);
    });
  });

  group('Formatters.whatsappLink', () {
    test('normalizes Moroccan 0-prefix to 212', () {
      final link = Formatters.whatsappLink(phone: '0612345678');
      expect(link, contains('212612345678'));
    });

    test('strips + prefix', () {
      final link = Formatters.whatsappLink(phone: '+212612345678');
      expect(link, contains('212612345678'));
      expect(link, isNot(contains('+'))); // wa.me uses no +
    });

    test('removes spaces and dashes', () {
      final link = Formatters.whatsappLink(phone: '06 12-34 56 78');
      expect(link, contains('212612345678'));
    });

    test('appends encoded message when provided', () {
      final link = Formatters.whatsappLink(
        phone: '0612345678',
        message: 'Hello World',
      );
      expect(link, contains('?text='));
      expect(link, contains('Hello'));
    });

    test('no message parameter when message is null', () {
      final link = Formatters.whatsappLink(phone: '0612345678');
      expect(link, isNot(contains('?text=')));
    });
  });

  group('Formatters.generateWhatsAppOrderMessage', () {
    test('includes all required elements', () {
      final msg = Formatters.generateWhatsAppOrderMessage(
        orderId: 'abc12345-6789',
        retailerName: 'Boutique Youssef',
        items: [
          {'qty': 5, 'name': 'Cable Type C', 'price_per_unit': 15.0},
          {'qty': 10, 'name': 'Screen A54', 'price_per_unit': 120.0},
        ],
        totalAmount: 1275.0,
      );

      expect(msg, contains('السلام عليكم')); // Salaam
      expect(msg, contains('ABC12345')); // Order ref (uppercase, 8 chars)
      expect(msg, contains('Boutique Youssef')); // Client name
      expect(msg, contains('Cable Type C')); // Item name
      expect(msg, contains('1275.00 DH')); // Total
    });

    test('includes notes when provided', () {
      final msg = Formatters.generateWhatsAppOrderMessage(
        orderId: 'abc12345-6789',
        retailerName: 'Test Shop',
        items: [
          {'qty': 1, 'name': 'Item', 'price_per_unit': 10.0},
        ],
        totalAmount: 10.0,
        notes: 'Urgent delivery needed',
      );

      expect(msg, contains('Notes: Urgent delivery needed'));
    });
  });
}
