## Unreleased

- Added same-track overlap layout so conflicting events render side-by-side.
- Added actual-track drag support for moving event start and end times.
- Added bottom-handle resizing for actual-track event duration.
- Added `onEventUpdated` callback for parent-controlled schedule updates.
- Added `TimelineEvent.copyWith` for immutable event updates.

## 0.1.0

- Initial release of `parallel_timeline`.
- Added `TimelineEvent` for timeline data modeling.
- Added `TimelineGridPainter` for hour grid lines and center divider rendering.
- Added `DualColumnTimeline` for scrollable planned-vs-actual layout.
- Added a Flutter example app with overlapping planned and actual events.
- Added focused tests for models, painter behavior, layout positioning, and the example app.
