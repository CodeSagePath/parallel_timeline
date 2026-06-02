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
          ..line(p1: Offset.zero, p2: Offset(120, 0), color: _gridLineColor)
          ..line(p1: Offset(0, 60), p2: Offset(120, 60), color: _gridLineColor)
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
          ..line(p1: Offset(60, 0), p2: Offset(60, 180), color: _dividerColor),
      );
    });

    testWidgets('draws center divider at wide width', (tester) async {
      await _pumpGrid(tester, width: 240);

      expect(
        find.byType(CustomPaint),
        paints
          ..line(p1: Offset.zero, p2: Offset(240, 0), color: _gridLineColor)
          ..line(p1: Offset(0, 60), p2: Offset(240, 60), color: _gridLineColor)
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

  group('DualColumnTimeline', () {
    test('requires valid time range and hour height', () {
      expect(
        () => DualColumnTimeline(
          plannedEvents: const [],
          actualEvents: const [],
          hourHeight: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => DualColumnTimeline(
          plannedEvents: const [],
          actualEvents: const [],
          startHour: 18,
          endHour: 8,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('uses a scroll view, stack, and grid painter', (tester) async {
      await _pumpTimeline(tester);

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
      expect(_timelineGridPaintFinder, findsOneWidget);
    });

    testWidgets('positions planned events in the left column', (tester) async {
      await _pumpTimeline(tester);

      final stackTopLeft = tester.getTopLeft(find.byType(Stack));
      final plannedTopLeft = tester.getTopLeft(find.byKey(_plannedEventKey));
      final plannedSize = tester.getSize(find.byKey(_plannedEventKey));

      expect(plannedTopLeft.dx - stackTopLeft.dx, 0);
      expect(plannedTopLeft.dy - stackTopLeft.dy, 60);
      expect(plannedSize.width, 100);
      expect(plannedSize.height, 30);
    });

    testWidgets('positions actual events in the right column', (tester) async {
      await _pumpTimeline(tester);

      final stackTopLeft = tester.getTopLeft(find.byType(Stack));
      final actualTopLeft = tester.getTopLeft(find.byKey(_actualEventKey));
      final actualSize = tester.getSize(find.byKey(_actualEventKey));

      expect(actualTopLeft.dx - stackTopLeft.dx, 100);
      expect(actualTopLeft.dy - stackTopLeft.dy, 90);
      expect(actualSize.width, 100);
      expect(actualSize.height, 60);
    });
  });
}

const _gridLineColor = Color(0xFFFF0000);
const _dividerColor = Color(0xFF0000FF);
const _backgroundColor = Color(0xFFFFFFFF);

final _timelineGridPaintFinder = find.byWidgetPredicate((widget) {
  return widget is CustomPaint && widget.painter is TimelineGridPainter;
});

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

final _plannedEventKey = ValueKey('planned-${_plannedEvent.id}');
final _actualEventKey = ValueKey('actual-${_actualEvent.id}');

final _plannedEvent = TimelineEvent(
  id: 'planned-focus',
  title: 'Planned Focus',
  startTime: DateTime(2026, 6, 2, 9),
  endTime: DateTime(2026, 6, 2, 9, 30),
  backgroundColor: const Color(0xFF1A73E8),
);

final _actualEvent = TimelineEvent(
  id: 'actual-focus',
  title: 'Actual Focus',
  startTime: DateTime(2026, 6, 2, 9, 30),
  endTime: DateTime(2026, 6, 2, 10, 30),
  backgroundColor: const Color(0xFF34A853),
);

Future<void> _pumpTimeline(WidgetTester tester) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: 200,
          height: 120,
          child: DualColumnTimeline(
            plannedEvents: [_plannedEvent],
            actualEvents: [_actualEvent],
            hourHeight: 60,
            startHour: 8,
            endHour: 12,
          ),
        ),
      ),
    ),
  );
}
