import 'package:flutter/material.dart';

import '../../models/activity.dart';
import '../../navigation/route_names.dart';
import '../../themes/app_themes.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/floating_bottom_nav.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final List<Activity> _activities = [
    Activity(
      id: '1',
      title: 'Team Meeting',
      description: 'Weekly team sync meeting',
      date: DateTime(2024, 1, 15, 10, 0),
      type: ActivityType.meeting,
      status: ActivityStatus.completed,
    ),
    Activity(
      id: '2',
      title: 'Project Deadline',
      description: 'Submit Q1 project report',
      date: DateTime(2024, 1, 20, 17, 0),
      type: ActivityType.deadline,
      status: ActivityStatus.pending,
    ),
    Activity(
      id: '3',
      title: 'Training Session',
      description: 'New software tools training',
      date: DateTime(2024, 1, 18, 14, 0),
      type: ActivityType.training,
      status: ActivityStatus.upcoming,
    ),
    Activity(
      id: '4',
      title: 'Client Presentation',
      description: 'Present project progress to client',
      date: DateTime(2024, 1, 22, 11, 0),
      type: ActivityType.presentation,
      status: ActivityStatus.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Activities',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          _activities.isEmpty
              ? Center(
                  child: Text(
                    'No activities found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppThemes.hintColor,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return _buildActivityCard(context, activity);
                  },
                ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNav(
              currentRoute: RouteNames.activities,
              onQRScanTap: () {
                NavigationHelper.navigateWithoutAnimation(
                  context,
                  RouteNames.qrScan,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.cardTheme.color,
      shape: theme.cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActivityTypeChip(activity.type),
                _buildStatusChip(activity.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppThemes.hintColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppThemes.hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(activity.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemes.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeChip(ActivityType type) {
    final Map<ActivityType, Map<String, dynamic>> typeData = {
      ActivityType.meeting: {
        'label': 'Meeting',
        'color': AppThemes.infoColor,
        'lightColor': AppThemes.infoLight,
      },
      ActivityType.deadline: {
        'label': 'Deadline',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      ActivityType.training: {
        'label': 'Training',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      ActivityType.presentation: {
        'label': 'Presentation',
        'color': AppThemes.primaryColor,
        'lightColor': AppThemes.primaryColor.withOpacity(0.1),
      },
    };

    final data = typeData[type]!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? data['color'].withOpacity(0.2) : data['lightColor'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data['color'].withOpacity(0.3), width: 1),
      ),
      child: Text(
        data['label'],
        style: TextStyle(
          color: data['color'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(ActivityStatus status) {
    final Map<ActivityStatus, Map<String, dynamic>> statusData = {
      ActivityStatus.completed: {
        'label': 'Completed',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      ActivityStatus.pending: {
        'label': 'Pending',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      ActivityStatus.upcoming: {
        'label': 'Upcoming',
        'color': AppThemes.infoColor,
        'lightColor': AppThemes.infoLight,
      },
      ActivityStatus.cancelled: {
        'label': 'Cancelled',
        'color': AppThemes.errorColor,
        'lightColor': AppThemes.errorLight,
      },
    };

    final data = statusData[status]!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? data['color'].withOpacity(0.2) : data['lightColor'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data['color'].withOpacity(0.3), width: 1),
      ),
      child: Text(
        data['label'],
        style: TextStyle(
          color: data['color'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Filter Activities',
        content: 'Filter options will be implemented here',
        primaryButtonText: 'Apply',
        onPrimaryButtonPressed: () => Navigator.pop(context),
        secondaryButtonText: 'Cancel',
      ),
    );
  }
}
