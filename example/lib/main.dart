import 'package:flutter/material.dart';
import 'package:parallel_timeline/parallel_timeline.dart';

void main() {
  runApp(const TimelineExampleApp());
}

class TimelineExampleApp extends StatelessWidget {
  const TimelineExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parallel Timeline Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
      ),
      home: const TimelineExampleScreen(),
    );
  }
}

class TimelineExampleScreen extends StatelessWidget {
  const TimelineExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parallel Timeline Example')),
      body: SafeArea(
        child: Column(
          children: [
            const _TrackHeader(),
            Expanded(
              child: DualColumnTimeline(
                plannedEvents: plannedEvents,
                actualEvents: actualEvents,
                startHour: 8,
                endHour: 15,
                hourHeight: 96,
                eventBuilder: _buildEventCard,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, TimelineEvent event) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: event.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        event.title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TrackHeader extends StatelessWidget {
  const _TrackHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text('Planned')),
            Expanded(child: Text('Actual')),
          ],
        ),
      ),
    );
  }
}

final plannedEvents = [
  TimelineEvent(
    id: 'plan-research',
    title: 'AI Research Brief',
    startTime: DateTime(2026, 6, 2, 8, 30),
    endTime: DateTime(2026, 6, 2, 10),
    backgroundColor: const Color(0xFF1A73E8),
  ),
  TimelineEvent(
    id: 'plan-prototype',
    title: 'Prototype Timeline Flow',
    startTime: DateTime(2026, 6, 2, 10, 30),
    endTime: DateTime(2026, 6, 2, 12, 30),
    backgroundColor: const Color(0xFF673AB7),
  ),
  TimelineEvent(
    id: 'plan-review',
    title: 'Review AI Output',
    startTime: DateTime(2026, 6, 2, 13),
    endTime: DateTime(2026, 6, 2, 14, 30),
    backgroundColor: const Color(0xFF00897B),
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
  TimelineEvent(
    id: 'actual-debug',
    title: 'Debug Generated UI',
    startTime: DateTime(2026, 6, 2, 11),
    endTime: DateTime(2026, 6, 2, 13, 30),
    backgroundColor: const Color(0xFFD81B60),
  ),
];
