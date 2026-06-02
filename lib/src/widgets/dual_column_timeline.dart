import 'package:flutter/material.dart';

import '../models/timeline_event.dart';
import '../painters/timeline_grid_painter.dart';

/// Builds the visual content for a timeline [event].
///
/// Use this callback to customize how event cards are rendered while keeping
/// the package's time-based positioning behavior.
typedef TimelineEventBuilder =
    Widget Function(BuildContext context, TimelineEvent event);

/// Displays planned and actual events in two time-aligned columns.
///
/// [plannedEvents] are rendered in the left column and [actualEvents] are
/// rendered in the right column. Event vertical positions are calculated from
/// [startHour], [endHour], and [hourHeight].
class DualColumnTimeline extends StatelessWidget {
  /// Creates a scrollable dual-column timeline.
  ///
  /// The [hourHeight] must be greater than zero, [startHour] must be between
  /// 0 and 23, and [endHour] must be after [startHour] and no greater than 24.
  const DualColumnTimeline({
    super.key,
    required this.plannedEvents,
    required this.actualEvents,
    this.hourHeight = 60,
    this.startHour = 0,
    this.endHour = 24,
    this.eventBuilder,
  }) : assert(hourHeight > 0, 'hourHeight must be greater than zero.'),
       assert(
         startHour >= 0 && startHour < 24,
         'startHour must be between 0 and 23.',
       ),
       assert(
         endHour > startHour && endHour <= 24,
         'endHour must be after startHour and no greater than 24.',
       );

  /// Events rendered in the left planned column.
  final List<TimelineEvent> plannedEvents;

  /// Events rendered in the right actual column.
  final List<TimelineEvent> actualEvents;

  /// Vertical space, in logical pixels, used for each hour.
  final double hourHeight;

  /// First visible hour in the timeline.
  final int startHour;

  /// Last visible hour in the timeline.
  final int endHour;

  /// Optional builder for custom event card content.
  final TimelineEventBuilder? eventBuilder;

  /// Builds the scrollable stack-based timeline layout.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnWidth = width / 2;
        final timelineHeight = (endHour - startHour) * hourHeight;

        return SingleChildScrollView(
          child: SizedBox(
            width: width,
            height: timelineHeight,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: TimelineGridPainter(hourHeight: hourHeight),
                  ),
                ),
                ..._positionedEvents(
                  context: context,
                  events: plannedEvents,
                  left: 0,
                  columnWidth: columnWidth,
                  trackName: 'planned',
                ),
                ..._positionedEvents(
                  context: context,
                  events: actualEvents,
                  left: columnWidth,
                  columnWidth: columnWidth,
                  trackName: 'actual',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _positionedEvents({
    required BuildContext context,
    required List<TimelineEvent> events,
    required double left,
    required double columnWidth,
    required String trackName,
  }) {
    return events.map((event) {
      return Positioned(
        top: _topOffset(event),
        left: left,
        width: columnWidth,
        height: _eventHeight(event),
        child: SizedBox(
          key: ValueKey('$trackName-${event.id}'),
          child: _buildEvent(context, event),
        ),
      );
    }).toList();
  }

  Widget _buildEvent(BuildContext context, TimelineEvent event) {
    final builder = eventBuilder;
    if (builder != null) {
      return builder(context, event);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      color: event.backgroundColor,
      child: Text(event.title),
    );
  }

  double _topOffset(TimelineEvent event) {
    final minutesFromStart = _minutesFromVisibleStart(event.startTime);

    return minutesFromStart * hourHeight / Duration.minutesPerHour;
  }

  double _eventHeight(TimelineEvent event) {
    return event.durationInMinutes * hourHeight / Duration.minutesPerHour;
  }

  int _minutesFromVisibleStart(DateTime time) {
    final visibleStart = DateTime(time.year, time.month, time.day, startHour);

    return time.difference(visibleStart).inMinutes;
  }
}
