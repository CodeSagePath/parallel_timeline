import 'package:flutter/rendering.dart';

/// Paints the static background grid behind a dual-column timeline.
///
/// The painter draws horizontal hour lines spaced by [hourHeight] and one
/// vertical divider through the exact center of the available width.
class TimelineGridPainter extends CustomPainter {
  /// Creates a painter for timeline hour lines and the center divider.
  const TimelineGridPainter({
    required this.hourHeight,
    this.gridLineColor = const Color(0xFFE0E0E0),
    this.dividerColor = const Color(0xFF9E9E9E),
    this.strokeWidth = 1,
  }) : assert(hourHeight > 0, 'hourHeight must be greater than zero.'),
       assert(strokeWidth > 0, 'strokeWidth must be greater than zero.');

  /// Vertical spacing, in logical pixels, between each hour line.
  final double hourHeight;

  /// Color used for horizontal hour lines.
  final Color gridLineColor;

  /// Color used for the vertical divider between the two columns.
  final Color dividerColor;

  /// Stroke width used for grid and divider lines.
  final double strokeWidth;

  /// Draws the hour lines and center divider into the provided [canvas].
  @override
  void paint(Canvas canvas, Size size) {
    _paintHourLines(canvas, size);
    _paintCenterDivider(canvas, size);
  }

  void _paintHourLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridLineColor
      ..strokeWidth = strokeWidth;

    for (var y = 0.0; y <= size.height; y += hourHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintCenterDivider(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final paint = Paint()
      ..color = dividerColor
      ..strokeWidth = strokeWidth;

    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
  }

  /// Returns true when a visual configuration value changes.
  @override
  bool shouldRepaint(TimelineGridPainter oldDelegate) {
    return hourHeight != oldDelegate.hourHeight ||
        gridLineColor != oldDelegate.gridLineColor ||
        dividerColor != oldDelegate.dividerColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
