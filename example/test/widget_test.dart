import 'package:flutter_test/flutter_test.dart';
import 'package:parallel_timeline/parallel_timeline.dart';
import 'package:parallel_timeline_example/main.dart';

void main() {
  testWidgets('renders the timeline example app', (tester) async {
    await tester.pumpWidget(const TimelineExampleApp());

    expect(find.text('Parallel Timeline Example'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Actual'), findsOneWidget);
    expect(find.byType(DualColumnTimeline), findsOneWidget);
    expect(find.text('AI Research Brief'), findsOneWidget);
    expect(find.text('Prompt Iteration'), findsOneWidget);
  });
}
