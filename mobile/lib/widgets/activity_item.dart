import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../themes/app_themes.dart';

class ActivityItem extends StatelessWidget {
  final ActivityLog activity;

  const ActivityItem({Key? key, required this.activity}) : super(key: key);

  IconData _getIcon() {
    if (activity.action.contains('CREATE')) return Icons.add_circle_outline;
    if (activity.action.contains('UPDATE')) return Icons.edit_outlined;
    if (activity.action.contains('DELETE')) return Icons.delete_outline;
    if (activity.action.contains('LOGIN')) return Icons.login;
    return Icons.history;
  }

  Color _getColor(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    
    if (activity.action.contains('CREATE')) return colors.success;
    if (activity.action.contains('UPDATE')) return colors.info;
    if (activity.action.contains('DELETE')) return colorScheme.error;
    return colors.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColor(context).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  color: _getColor(context),
                  size: 20,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(activity.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      backgroundImage: activity.user?.avatar != null
                          ? NetworkImage(activity.user!.avatar!)
                          : null,
                      child: activity.user?.avatar == null
                          ? Icon(
                              Icons.person,
                              size: 10,
                              color: colors.textSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${activity.user?.username ?? 'System'} • ${activity.action}",
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
