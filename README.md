# Parallel Timeline

`parallel_timeline` is a Flutter package for rendering planned and actual
events in a time-aligned, dual-column timeline.

Use it when you need to compare two tracks against the same clock, such as an
AI-generated plan versus actual execution, scheduled work versus completed work,
or any side-by-side timeline where duration and start time matter.

## Features

- Dual-column timeline for planned and actual events.
- Time-based event positioning from `startTime` and `durationInMinutes`.
- Configurable visible time range with `startHour` and `endHour`.
- Configurable vertical density through `hourHeight`.
- Left-side time axis labels for each visible hour.
- Built-in current time indicator for the active day.
- Event spacing so cards do not sit flush against dividers or edges.
- Same-track overlap handling that places conflicting events side-by-side.
- Interactive actual-track editing with drag and resize callbacks.
- Custom event cards with `eventBuilder`.
- Built-in grid painter with horizontal hour lines and a center divider.
- Example app under `example/`.

## Getting Started

Add the package to your Flutter project:

```yaml
dependencies:
  parallel_timeline: ^0.1.0
```

Import the package:

```dart
import 'package:flutter/material.dart';
import 'package:parallel_timeline/parallel_timeline.dart';
```

## Usage

Create `TimelineEvent` values for the planned and actual tracks, then render a
`DualColumnTimeline`.

```dart
final plannedEvents = [
  TimelineEvent(
    id: 'plan-research',
    title: 'AI Research Brief',
    startTime: DateTime(2026, 6, 2, 8, 30),
    endTime: DateTime(2026, 6, 2, 10),
    backgroundColor: const Color(0xFF1A73E8),
  ),
];

final actualEvents = [
  TimelineEvent(
    id: 'actual-prompting',
    title: 'Prompt Iteration',
    startTime: DateTime(2026, 6, 2, 9, 15),
    endTime: DateTime(2026, 6, 2, 11, 15),
    backgroundColor: const Color(0xFFEF6C00),
  ),
];

DualColumnTimeline(
  plannedEvents: plannedEvents,
  actualEvents: actualEvents,
  startHour: 8,
  endHour: 15,
  hourHeight: 96,
  timeAxisWidth: 56,
  eventSpacing: 6,
  onEventUpdated: (oldEvent, newEvent) {
    // Replace oldEvent with newEvent in your app state.
  },
);
```

Actual-track events can be dragged vertically to move their start and end time
together. Drag the bottom handle to resize the event duration. The widget calls
`onEventUpdated` with the original event and the updated event so the parent can
persist the change.

Customize event cards with `eventBuilder`:

```dart
DualColumnTimeline(
  plannedEvents: plannedEvents,
  actualEvents: actualEvents,
  eventBuilder: (context, event) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: event.backgroundColor,
      child: Text(event.title),
    );
  },
);
```

## Example

Run the included example app:

```bash
cd example
flutter run
```

The example demonstrates three planned AI events and two actual execution events
with intentional overlaps.

## Quality

The package includes focused tests for:

- `TimelineEvent` validation and duration calculations.
- `TimelineGridPainter` repaint behavior and line placement.
- `DualColumnTimeline` stack structure, event positioning, and overlap lanes.

Run checks from the package root:

```bash
flutter analyze
flutter test
```

## License

This package is released under the license included in `LICENSE`.
