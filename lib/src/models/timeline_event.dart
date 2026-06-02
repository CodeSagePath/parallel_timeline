import 'package:flutter/material.dart';

/// A scheduled timeline item with a fixed start and end time.
class TimelineEvent {
  /// Creates a timeline event.
  TimelineEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.backgroundColor,
  }) : assert(
          endTime.isAfter(startTime),
          'endTime must be strictly after startTime.',
        );

  /// Stable identifier for the event.
  final String id;

  /// Display title for the event.
  final String title;

  /// Time when the event begins.
  final DateTime startTime;

  /// Time when the event ends.
  final DateTime endTime;

  /// Background color used when rendering the event.
  final Color backgroundColor;

  /// Event duration in whole minutes.
  int get durationInMinutes => endTime.difference(startTime).inMinutes;
}
