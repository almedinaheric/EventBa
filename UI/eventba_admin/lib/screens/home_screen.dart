import 'package:eventba_admin/screens/categories_screen.dart';
import 'package:eventba_admin/screens/event_creation_screen.dart';
import 'package:eventba_admin/screens/private_events_screen.dart';
import 'package:eventba_admin/screens/public_events_screen.dart';
import 'package:eventba_admin/screens/users_screen.dart';
import 'package:eventba_admin/screens/report_generation_screen.dart';
import 'package:eventba_admin/screens/support_screen.dart';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:eventba_admin/screens/notification_creation_screen.dart';
import 'package:eventba_admin/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MasterScreen(
        title: 'EventBa',
        showBackButton: false,
        body: _buildHomeContent(context),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSeparator = constraints.maxWidth > 600;
        return showSeparator ? _buildDesktopLayout() : _buildMobileLayout();
      },
    );
  }

  Widget _buildDesktopLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                flex: 1,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.525,
                  children: [
                    _buildCard('Add Event'),
                    _buildCard('Add Notification'),
                    _buildCard('Generate Report'),
                  ],
                ),
              ),
              // Vertical separator
              Container(
                height: constraints.maxHeight,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.withOpacity(0.1),
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
              // Right column
              Expanded(
                flex: 2,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildCard('Public Events'),
                    _buildCard('Private Events'),
                    _buildCard('Users'),
                    _buildCard('Notifications'),
                    _buildCard('Support'),
                    _buildCard('Manage Categories'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildCard('Add Event'),
        _buildCard('Add Notification'),
        _buildCard('Generate Report'),
        _buildCard('Public Events'),
        _buildCard('Private Events'),
        _buildCard('Users'),
        _buildCard('Notifications'),
        _buildCard('Support'),
      ],
    );
  }

  Widget _buildCard(String title) {
    IconData icon;
    Color color = const Color(0xFF4776E6);

    switch (title) {
      case 'Add Event':
        icon = Icons.add_circle_outline;
        break;
      case 'Public Events':
        icon = Icons.public;
        break;
      case 'Private Events':
        icon = Icons.lock_outline;
        break;
      case 'Add Notification':
        icon = Icons.add_alert_outlined;
        break;
      case 'Users':
        icon = Icons.people_outline;
        break;
      case 'Notifications':
        icon = Icons.notifications_outlined;
        break;
      case 'Support':
        icon = Icons.support_agent_outlined;
        break;
      case 'Generate Report':
      case 'Reports':
        icon = Icons.assessment_outlined;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            color: Colors.white,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _navigateToScreen(context, title),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1.2,
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

  void _navigateToScreen(BuildContext context, String screenName) {
    if (screenName == 'Add Event') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EventCreationScreen()),
      );
    }
    if (screenName == 'Private Events') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PrivateEventsScreen()),
      );
    }
    if (screenName == 'Add Notification') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationCreationScreen(),
        ),
      );
    }
    if (screenName == 'Users') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UsersScreen()),
      );
    }
    if (screenName == 'Notifications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
    }
    if (screenName == 'Support') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupportScreen()),
      );
    }
    if (screenName == 'Public Events') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PublicEventsScreen()),
      );
    }
    if (screenName == 'Generate Report') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReportGenerationScreen()),
      );
    }
    if (screenName == 'Manage Categories') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoriesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to $screenName'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
