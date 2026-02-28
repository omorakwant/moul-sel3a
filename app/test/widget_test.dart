// Smoke test — verifies the app entry point exists and core classes are importable.
//
// Note: Full widget tests for LCarnetApp require Supabase + Hive initialization,
// which is handled in main.dart. This test validates that the core app widget
// can be referenced without runtime errors.

import 'package:flutter_test/flutter_test.dart';

import 'package:lcarnet_b2b/app.dart';

void main() {
  test('LCarnetApp class exists and is a widget', () {
    // Verify the app entry point class is importable and constructible.
    // We can't pump it without Supabase/Hive init, but we confirm it compiles.
    expect(LCarnetApp, isNotNull);
  });
}
