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

  group('TimelineGridPainter', () {
    test('repaints only when configuration changes', () {
      const painter = TimelineGridPainter(hourHeight: 60);

      expect(
        painter.shouldRepaint(const TimelineGridPainter(hourHeight: 60)),
        isFalse,
      );
      expect(
        painter.shouldRepaint(const TimelineGridPainter(hourHeight: 30)),
        isTrue,
      );
    });

    test('requires positive dimensions', () {
      expect(
        () => TimelineGridPainter(hourHeight: 0),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => TimelineGridPainter(hourHeight: 60, strokeWidth: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('draws hour lines and center divider at narrow width', (
      tester,
    ) async {
      await _pumpGrid(tester, width: 120);

      expect(
        find.byType(CustomPaint),
        paints
          ..line(
            p1: Offset.zero,
            p2: Offset(120, 0),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 60),
            p2: Offset(120, 60),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 120),
            p2: Offset(120, 120),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 180),
            p2: Offset(120, 180),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(60, 0),
            p2: Offset(60, 180),
            color: _dividerColor,
          ),
      );
    });

    testWidgets('draws center divider at wide width', (tester) async {
      await _pumpGrid(tester, width: 240);

      expect(
        find.byType(CustomPaint),
        paints
          ..line(
            p1: Offset.zero,
            p2: Offset(240, 0),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 60),
            p2: Offset(240, 60),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 120),
            p2: Offset(240, 120),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(0, 180),
            p2: Offset(240, 180),
            color: _gridLineColor,
          )
          ..line(
            p1: Offset(120, 0),
            p2: Offset(120, 180),
            color: _dividerColor,
          ),
      );
    });
  });
}

const _gridLineColor = Color(0xFFFF0000);
const _dividerColor = Color(0xFF0000FF);
const _backgroundColor = Color(0xFFFFFFFF);

Future<void> _pumpGrid(WidgetTester tester, {required double width}) async {
  await tester.pumpWidget(
    Center(
      child: SizedBox(
        width: width,
        height: 180,
        child: ColoredBox(
          color: _backgroundColor,
          child: CustomPaint(
            painter: const TimelineGridPainter(
              hourHeight: 60,
              gridLineColor: _gridLineColor,
              dividerColor: _dividerColor,
            ),
          ),
        ),
      ),
    ),
  );
}
