import 'dart:async';

import 'package:flutter/material.dart';

import '../models/timeline_event.dart';
import '../painters/timeline_grid_painter.dart';

/// Builds the visual content for a timeline [event].
///
/// Use this callback to customize how event cards are rendered while keeping
/// the package's time-based positioning behavior.
typedef TimelineEventBuilder =
    Widget Function(BuildContext context, TimelineEvent event);

/// Reports that a timeline [oldEvent] was edited into [newEvent].
///
/// The parent widget should update its own event list with [newEvent] and pass
/// the updated list back into [DualColumnTimeline].
typedef TimelineEventUpdatedCallback =
    void Function(TimelineEvent oldEvent, TimelineEvent newEvent);

/// Displays planned and actual events in two time-aligned columns.
///
/// [plannedEvents] are rendered in the left column and [actualEvents] are
/// rendered in the right column. Event vertical positions are calculated from
/// [startHour], [endHour], and [hourHeight].
class DualColumnTimeline extends StatefulWidget {
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
    this.timeAxisWidth = 56,
    this.eventSpacing = 6,
    this.showCurrentTimeIndicator = true,
    this.currentTime,
    this.currentTimeUpdateInterval = const Duration(minutes: 1),
    this.currentTimeIndicatorKey,
    this.currentTimeIndicatorColor = Colors.red,
    this.onEventUpdated,
    this.eventBuilder,
  }) : assert(hourHeight > 0, 'hourHeight must be greater than zero.'),
       assert(timeAxisWidth >= 0, 'timeAxisWidth must not be negative.'),
       assert(eventSpacing >= 0, 'eventSpacing must not be negative.'),
       assert(
         currentTimeUpdateInterval > Duration.zero,
         'currentTimeUpdateInterval must be greater than zero.',
       ),
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

  /// Width reserved for the left-side time labels.
  final double timeAxisWidth;

  /// Inset applied around each positioned event block.
  final double eventSpacing;

  /// Whether to show the current time indicator when it falls in range.
  final bool showCurrentTimeIndicator;

  /// Time used by the current time indicator.
  ///
  /// Defaults to [DateTime.now] when omitted.
  final DateTime? currentTime;

  /// How often the current time indicator refreshes.
  final Duration currentTimeUpdateInterval;

  /// Optional key applied to the current time indicator.
  final Key? currentTimeIndicatorKey;

  /// Color used for the current time indicator line.
  final Color currentTimeIndicatorColor;

  /// Called when an actual-track event is moved or resized by the user.
  final TimelineEventUpdatedCallback? onEventUpdated;

  /// Optional builder for custom event card content.
  final TimelineEventBuilder? eventBuilder;

  @override
  State<DualColumnTimeline> createState() => _DualColumnTimelineState();
}

class _DualColumnTimelineState extends State<DualColumnTimeline> {
  late DateTime _now;
  Timer? _currentTimeTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _syncCurrentTimeTimer();
  }

  @override
  void didUpdateWidget(DualColumnTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showCurrentTimeIndicator != widget.showCurrentTimeIndicator ||
        oldWidget.currentTime != widget.currentTime ||
        oldWidget.currentTimeUpdateInterval !=
            widget.currentTimeUpdateInterval) {
      _syncCurrentTimeTimer();
    }
  }

  @override
  void dispose() {
    _currentTimeTimer?.cancel();
    super.dispose();
  }

  /// Builds the scrollable stack-based timeline layout.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final tracksWidth = (width - widget.timeAxisWidth).clamp(
          0.0,
          double.infinity,
        );
        final columnWidth = tracksWidth / 2;
        final timelineHeight =
            (widget.endHour - widget.startHour) * widget.hourHeight;
        final resolvedCurrentTime = widget.currentTime ?? _now;

        return SingleChildScrollView(
          child: SizedBox(
            width: width,
            height: timelineHeight,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: TimelineGridPainter(hourHeight: widget.hourHeight),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: widget.timeAxisWidth,
                  child: _TimeAxis(
                    startHour: widget.startHour,
                    endHour: widget.endHour,
                    hourHeight: widget.hourHeight,
                  ),
                ),
                ..._positionedEvents(
                  context: context,
                  events: widget.plannedEvents,
                  left: widget.timeAxisWidth,
                  columnWidth: columnWidth,
                  trackName: 'planned',
                  isEditable: false,
                ),
                ..._positionedEvents(
                  context: context,
                  events: widget.actualEvents,
                  left: widget.timeAxisWidth + columnWidth,
                  columnWidth: columnWidth,
                  trackName: 'actual',
                  isEditable: true,
                ),
                if (widget.showCurrentTimeIndicator)
                  _CurrentTimeIndicator(
                    currentTime: resolvedCurrentTime,
                    startHour: widget.startHour,
                    endHour: widget.endHour,
                    hourHeight: widget.hourHeight,
                    left: widget.timeAxisWidth,
                    width: tracksWidth,
                    indicatorKey: widget.currentTimeIndicatorKey,
                    color: widget.currentTimeIndicatorColor,
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
    required bool isEditable,
  }) {
    return events.map((event) {
      final child = Padding(
        padding: EdgeInsets.all(widget.eventSpacing),
        child: SizedBox(
          key: ValueKey('$trackName-${event.id}'),
          child: _buildEvent(context, event),
        ),
      );

      return Positioned(
        top: _topOffset(event),
        left: left,
        width: columnWidth,
        height: _eventHeight(event),
        child: isEditable && widget.onEventUpdated != null
            ? _EditableTimelineEvent(
                event: event,
                hourHeight: widget.hourHeight,
                onEventUpdated: widget.onEventUpdated!,
                child: child,
              )
            : child,
      );
    }).toList();
  }

  Widget _buildEvent(BuildContext context, TimelineEvent event) {
    final builder = widget.eventBuilder;
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

    return minutesFromStart * widget.hourHeight / Duration.minutesPerHour;
  }

  double _eventHeight(TimelineEvent event) {
    return event.durationInMinutes *
        widget.hourHeight /
        Duration.minutesPerHour;
  }

  int _minutesFromVisibleStart(DateTime time) {
    final visibleStart = DateTime(
      time.year,
      time.month,
      time.day,
      widget.startHour,
    );

    return time.difference(visibleStart).inMinutes;
  }

  void _syncCurrentTimeTimer() {
    _currentTimeTimer?.cancel();
    _currentTimeTimer = null;

    if (!widget.showCurrentTimeIndicator || widget.currentTime != null) {
      return;
    }

    _currentTimeTimer = Timer.periodic(widget.currentTimeUpdateInterval, (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }
}

class _EditableTimelineEvent extends StatefulWidget {
  const _EditableTimelineEvent({
    required this.event,
    required this.hourHeight,
    required this.onEventUpdated,
    required this.child,
  });

  final TimelineEvent event;
  final double hourHeight;
  final TimelineEventUpdatedCallback onEventUpdated;
  final Widget child;

  @override
  State<_EditableTimelineEvent> createState() => _EditableTimelineEventState();
}

class _EditableTimelineEventState extends State<_EditableTimelineEvent> {
  double _moveDeltaY = 0;
  double _resizeDeltaY = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) {
        _moveDeltaY = 0;
      },
      onVerticalDragUpdate: (details) {
        _moveDeltaY += details.delta.dy;
      },
      onVerticalDragEnd: (_) {
        _updateMovedEvent();
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) {
                _resizeDeltaY = 0;
              },
              onVerticalDragUpdate: (details) {
                _resizeDeltaY += details.delta.dy;
              },
              onVerticalDragEnd: (_) {
                _updateResizedEvent();
              },
              child: _ResizeHandle(eventId: widget.event.id),
            ),
          ),
        ],
      ),
    );
  }

  void _updateMovedEvent() {
    final minuteDelta = _minutesFromDelta(_moveDeltaY);
    if (minuteDelta == 0) {
      return;
    }

    widget.onEventUpdated(
      widget.event,
      widget.event.copyWith(
        startTime: widget.event.startTime.add(Duration(minutes: minuteDelta)),
        endTime: widget.event.endTime.add(Duration(minutes: minuteDelta)),
      ),
    );
  }

  void _updateResizedEvent() {
    final minuteDelta = _minutesFromDelta(_resizeDeltaY);
    if (minuteDelta == 0) {
      return;
    }

    final requestedEndTime = widget.event.endTime.add(
      Duration(minutes: minuteDelta),
    );
    final minimumEndTime = widget.event.startTime.add(
      const Duration(minutes: 1),
    );

    widget.onEventUpdated(
      widget.event,
      widget.event.copyWith(
        endTime: requestedEndTime.isAfter(minimumEndTime)
            ? requestedEndTime
            : minimumEndTime,
      ),
    );
  }

  int _minutesFromDelta(double deltaY) {
    return (deltaY * Duration.minutesPerHour / widget.hourHeight).round();
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: ValueKey('actual-$eventId-resize-handle'),
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _TimeAxis extends StatelessWidget {
  const _TimeAxis({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.grey.shade600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Stack(
      children: [
        for (var hour = startHour; hour <= endHour; hour++)
          Positioned(
            top: (hour - startHour) * hourHeight,
            left: 0,
            right: 8,
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                textAlign: TextAlign.right,
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  const _CurrentTimeIndicator({
    required this.currentTime,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.left,
    required this.width,
    required this.indicatorKey,
    required this.color,
  });

  final DateTime currentTime;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final double left;
  final double width;
  final Key? indicatorKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final minutes = _minutesFromVisibleStart();
    final visibleMinutes = (endHour - startHour) * Duration.minutesPerHour;
    if (minutes < 0 || minutes > visibleMinutes) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: left,
      top: minutes * hourHeight / Duration.minutesPerHour,
      width: width,
      child: IgnorePointer(
        child: DecoratedBox(
          key: indicatorKey,
          decoration: BoxDecoration(color: color),
          child: const SizedBox(height: 2),
        ),
      ),
    );
  }

  int _minutesFromVisibleStart() {
    final visibleStart = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      startHour,
    );

    return currentTime.difference(visibleStart).inMinutes;
  }
}
