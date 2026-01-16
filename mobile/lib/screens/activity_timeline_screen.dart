import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/logbook_provider.dart';
import '../widgets/activity_item.dart';
import '../widgets/custom_drawer.dart';

class ActivityTimelineScreen extends StatefulWidget {
  const ActivityTimelineScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTimelineScreen> createState() => _ActivityTimelineScreenState();
}

class _ActivityTimelineScreenState extends State<ActivityTimelineScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LogbookProvider>(context, listen: false).fetchActivities();
    });
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Export Activity Log", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text("Export as CSV"),
                onTap: () {
                  Navigator.pop(context);
                  _handleExport('csv');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleExport(String format) async {
    final provider = Provider.of<LogbookProvider>(context, listen: false);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading..."), duration: Duration(seconds: 2)),
      );
      
      await provider.exportData(type: 'activity', format: format);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download successful! Opening file..."), backgroundColor: Colors.green),
      );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Export failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Activity Timeline"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Consumer<LogbookProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No activities recorded yet."),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchActivities(),
            child: ListView.builder(
              itemCount: provider.activities.length,
              itemBuilder: (context, index) {
                final activity = provider.activities[index];
                
                // Group by Date Header? For simplicity, just list items.
                // We can add date headers logic here if we really want to mimic the Web UI.
                return ActivityItem(activity: activity);
              },
            ),
          );
        },
      ),
    );
  }
}
