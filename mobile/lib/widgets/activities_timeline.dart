import 'package:flutter/material.dart';

import '../../../models/timeline_activity.dart'; // Pastikan model ini ada
import '../../../themes/app_themes.dart';

class ActivitiesTimeline extends StatelessWidget {
  final List<TimelineActivity> activities;

  const ActivitiesTimeline({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurface : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Timeline",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark
                  ? AppThemes.darkTextPrimary
                  : AppThemes.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final item = activities[index];
              final isLast = index == activities.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppThemes.getProgressColor(item.status),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppThemes.darkSurface
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDark
                                    ? AppThemes.darkOutline
                                    : Colors.grey.shade200,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark
                                        ? AppThemes.darkTextPrimary
                                        : AppThemes.onSurfaceColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppThemes.getProgressColor(
                                      item.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemes.getProgressColor(
                                        item.status,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.activity,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppThemes.darkTextSecondary
                                    : AppThemes.onSurfaceColor.withOpacity(0.8),
                              ),
                            ),
                            if (item.location.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: AppThemes.hintColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.location,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppThemes.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
