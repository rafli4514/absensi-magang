import 'package:flutter/material.dart';

import '../../../models/activity.dart';
import '../../../models/enum/activity_status.dart';
import '../../../models/enum/activity_type.dart';
import '../../../themes/app_themes.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isDark;

  const ActivityCard({super.key, required this.activity, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(activity.status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkSurfaceElevated : AppThemes.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppThemes.darkOutline : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(activity.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(activity.type),
                      color: _getTypeColor(activity.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activity.kegiatan,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? AppThemes.darkTextPrimary
                                    : AppThemes.onSurfaceColor,
                              ),
                            ),
                            if (activity.status == ActivityStatus.pending)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppThemes.errorColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.deskripsi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppThemes.darkTextSecondary
                                : AppThemes.hintColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: AppThemes.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${activity.tanggal}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppThemes.hintColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                activity.status
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.completed:
        return AppThemes.successColor;
      case ActivityStatus.pending:
        return AppThemes.errorColor;
      case ActivityStatus.inProgress:
        return AppThemes.infoColor;
      default:
        return AppThemes.neutralColor;
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.meeting:
        return AppThemes.infoColor;
      case ActivityType.deadline:
        return AppThemes.errorColor;
      case ActivityType.presentation:
        return AppThemes.successColor;
      case ActivityType.training:
        return AppThemes.warningColor;
      default:
        return AppThemes.primaryColor;
    }
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.meeting:
        return Icons.groups_outlined;
      case ActivityType.deadline:
        return Icons.timer_outlined;
      case ActivityType.presentation:
        return Icons.present_to_all;
      case ActivityType.training:
        return Icons.school_outlined;
      default:
        return Icons.work_outline;
    }
  }
}
