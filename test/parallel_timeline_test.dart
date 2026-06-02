import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parallel_timeline/parallel_timeline.dart';

void main() {
  group('TimelineEvent', () {
    test('stores event details', () {
      final startTime = DateTime(2026, 6, 2, 9);
      final endTime = DateTime(2026, 6, 2, 10, 30);

      const backgroundColor = Color(0xFF1A73E8);
      final event = TimelineEvent(
        id: 'planning',
        title: 'Planning',
        startTime: startTime,
        endTime: endTime,
        backgroundColor: backgroundColor,
      );

      expect(event.id, 'planning');
      expect(event.title, 'Planning');
      expect(event.startTime, startTime);
      expect(event.endTime, endTime);
      expect(event.backgroundColor, backgroundColor);
    });

    test('calculates duration in minutes', () {
      final event = TimelineEvent(
        id: 'build',
        title: 'Build',
        startTime: DateTime(2026, 6, 2, 11, 15),
        endTime: DateTime(2026, 6, 2, 12),
        backgroundColor: const Color(0xFF34A853),
      );

      expect(event.durationInMinutes, 45);
    });

    test('requires endTime to be after startTime', () {
      final startTime = DateTime(2026, 6, 2, 13);

      expect(
        () => TimelineEvent(
          id: 'invalid',
          title: 'Invalid',
          startTime: startTime,
          endTime: startTime,
          backgroundColor: const Color(0xFFEA4335),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
