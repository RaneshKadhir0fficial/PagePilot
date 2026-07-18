import 'package:flutter_test/flutter_test.dart';
import 'package:pagepilot/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('calculateRemainingDays returns correct days', () {
      expect(AppDateUtils.calculateRemainingDays(100, 10), 10);
      expect(AppDateUtils.calculateRemainingDays(15, 10), 2);
      expect(AppDateUtils.calculateRemainingDays(0, 10), 0);
    });

    test('calculateCurrentStreak with empty list returns 0', () {
      expect(AppDateUtils.calculateCurrentStreak([]), 0);
    });

    test('calculateLongestStreak with empty list returns 0', () {
      expect(AppDateUtils.calculateLongestStreak([]), 0);
    });
  });
}
