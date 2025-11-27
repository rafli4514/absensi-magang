import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../models/enum/activity_status.dart';
import '../../models/enum/activity_type.dart';
import '../../navigation/route_names.dart';
import '../../providers/theme_provider.dart';
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
      pesertaMagangId: '1',
      tanggal: '2024-01-15',
      kegiatan: 'Team Meeting',
      deskripsi: 'Weekly team sync meeting',
      type: ActivityType.meeting,
      status: ActivityStatus.completed,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    Activity(
      id: '2',
      pesertaMagangId: '1',
      tanggal: '2024-01-20',
      kegiatan: 'Project Deadline',
      deskripsi: 'Submit Q1 project report',
      type: ActivityType.deadline,
      status: ActivityStatus.pending,
      createdAt: DateTime(2024, 1, 20),
      updatedAt: DateTime(2024, 1, 20),
    ),
    Activity(
      id: '3',
      pesertaMagangId: '1',
      tanggal: '2024-01-18',
      kegiatan: 'Training Session',
      deskripsi: 'New software tools training',
      type: ActivityType.training,
      status: ActivityStatus.inProgress,
      createdAt: DateTime(2024, 1, 18),
      updatedAt: DateTime(2024, 1, 18),
    ),
    Activity(
      id: '4',
      pesertaMagangId: '1',
      tanggal: '2024-01-22',
      kegiatan: 'Client Presentation',
      deskripsi: 'Present project progress to client',
      type: ActivityType.presentation,
      status: ActivityStatus.pending,
      createdAt: DateTime(2024, 1, 22),
      updatedAt: DateTime(2024, 1, 22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

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
                    return _buildActivityCard(context, activity, isDarkMode);
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

  Widget _buildActivityCard(
    BuildContext context,
    Activity activity,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);

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
                _buildActivityTypeChip(activity.type, isDarkMode),
                _buildStatusChip(activity.status, isDarkMode),
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

  Widget _buildActivityTypeChip(ActivityType type, bool isDarkMode) {
    final Map<ActivityType, Map<String, dynamic>> typeData = {
      ActivityType.meeting: {
        'label': 'Meeting',
        'color': AppThemes.infoColor,
        'lightColor': AppThemes.infoLight,
      },
      ActivityType.training: {
        'label': 'Training',
        'color': AppThemes.warningColor,
        'lightColor': AppThemes.warningLight,
      },
      ActivityType.presentation: {
        'label': 'Presentation',
        'color': AppThemes.successColor,
        'lightColor': AppThemes.successLight,
      },
      ActivityType.deadline: {
        'label': 'Deadline',
        'color': AppThemes.errorColor,
        'lightColor': AppThemes.errorLight,
      },
      ActivityType.other: {
        'label': 'Other',
        'color': AppThemes.hintColor,
        'lightColor': AppThemes.hintColor.withOpacity(0.1),
      },
    };

    final data = typeData[type]!;

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

  Widget _buildStatusChip(ActivityStatus status, bool isDarkMode) {
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
      ActivityStatus.inProgress: {
        'label': 'In Progress',
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
