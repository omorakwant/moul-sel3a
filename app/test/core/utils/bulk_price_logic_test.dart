import 'package:flutter_test/flutter_test.dart';
import 'package:lcarnet_b2b/core/utils/bulk_price_logic.dart';

void main() {
  group('BulkPriceAdjustment.apply — fixedOffset', () {
    test('adds positive offset', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.fixedOffset,
        value: 10,
      );
      expect(adj.apply(100), 110);
    });

    test('subtracts negative offset', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.fixedOffset,
        value: -5,
      );
      expect(adj.apply(100), 95);
    });

    test('prevents negative result (clamps to 0.01)', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.fixedOffset,
        value: -200,
      );
      expect(adj.apply(100), 0.01);
    });
  });

  group('BulkPriceAdjustment.apply — percentageShift', () {
    test('applies positive percentage', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.percentageShift,
        value: 10, // +10%
      );
      expect(adj.apply(100), closeTo(110, 0.001));
    });

    test('applies negative percentage', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.percentageShift,
        value: -20, // -20%
      );
      expect(adj.apply(100), 80);
    });

    test('prevents negative result', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.percentageShift,
        value: -150, // -150%
      );
      expect(adj.apply(100), 0.01);
    });
  });

  group('BulkPriceAdjustment.apply — flatOverride', () {
    test('sets exact price', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.flatOverride,
        value: 50,
      );
      expect(adj.apply(100), 50);
      expect(adj.apply(200), 50);
    });

    test('prevents zero/negative price', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.flatOverride,
        value: -10,
      );
      expect(adj.apply(100), 0.01);
    });
  });

  group('BulkPriceAdjustment.applyToTiers', () {
    final tiers = <String, dynamic>{'1': 15.0, '10': 12.0, '50': 10.0};

    test('adjusts only tier 1 when applyToAllTiers is false', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.fixedOffset,
        value: 5,
        applyToAllTiers: false,
      );
      final result = adj.applyToTiers(tiers);

      expect(result['1'], 20.0); // 15 + 5
      expect(result['10'], 12.0); // unchanged
      expect(result['50'], 10.0); // unchanged
    });

    test('adjusts all tiers when applyToAllTiers is true', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.fixedOffset,
        value: 5,
        applyToAllTiers: true,
      );
      final result = adj.applyToTiers(tiers);

      expect(result['1'], 20.0); // 15 + 5
      expect(result['10'], 17.0); // 12 + 5
      expect(result['50'], 15.0); // 10 + 5
    });

    test('percentage applies to all tiers', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.percentageShift,
        value: 10, // +10%
        applyToAllTiers: true,
      );
      final result = adj.applyToTiers(tiers);

      expect(result['1'], 16.5); // 15 * 1.1
      expect(result['10'], 13.2); // 12 * 1.1
      expect(result['50'], 11.0); // 10 * 1.1
    });

    test('rounds to 2 decimal places', () {
      const adj = BulkPriceAdjustment(
        mode: BulkPriceMode.percentageShift,
        value: 33.33, // +33.33%
        applyToAllTiers: true,
      );
      final result = adj.applyToTiers({'1': 10.0});

      // 10 * 1.3333 = 13.333 → rounded to 13.33
      expect(result['1'], 13.33);
    });
  });

  group('BulkPricePreview', () {
    test('stores old and new prices', () {
      const preview = BulkPricePreview(
        productId: 'p1',
        productName: 'Cable Type C',
        oldPrices: {'1': 15.0, '10': 12.0},
        newPrices: {'1': 20.0, '10': 17.0},
      );

      expect(preview.productId, 'p1');
      expect(preview.productName, 'Cable Type C');
      expect(preview.oldPrices['1'], 15.0);
      expect(preview.newPrices['1'], 20.0);
    });
  });
}
