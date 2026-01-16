import 'package:flutter/material.dart';
import '../../models/activity_log.dart'; 
import '../../widgets/activity_item.dart';

class ActivitiesTimeline extends StatelessWidget {
  final List<ActivityLog> activities;

  const ActivitiesTimeline({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
               Icon(Icons.history, color: colorScheme.outline, size: 48),
               const SizedBox(height: 10),
               Text('Belum ada aktivitas tercatat', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        return ActivityItem(activity: activities[index]);
      },
    );
  }
}