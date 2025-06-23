import 'package:flutter/material.dart';

class MasterScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? appBarActions;
  final FloatingActionButton? floatingActionButton;
  final bool showBackButton;
  final PreferredSizeWidget? bottomAppBar;

  const MasterScreen({
    super.key,
    required this.title,
    required this.body,
    this.appBarActions,
    this.floatingActionButton,
    this.showBackButton = true,
    this.bottomAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Padding(
          padding:  EdgeInsets.only(left: 32.0),
          child: Text(
            'EventBa',
            style: TextStyle(
              fontWeight: FontWeight.w700, // Slightly bolder
              fontSize: 22, // Slightly larger
              color: Color(0xFF4776E6), // Updated to your blue color
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        automaticallyImplyLeading: showBackButton,
        actions: appBarActions ??
            [
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Admin Admin',
                      style: TextStyle(
                        color: Colors.grey[800], // Darker gray for better contrast
                        fontSize: 14,
                        fontWeight: FontWeight.w500, // Medium weight
                      ),
                    ),
                    const SizedBox(width: 12), // Slightly more spacing
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[400]!, // Light gray border
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.person_2_outlined,
                        size: 20, // Slightly larger
                        color: Colors.grey[600], // Darker gray
                      ),
                    ),
                  ],
                ),
              ),
            ],
        bottom: bottomAppBar,
      ),
      body: SafeArea(
        child: _buildResponsiveBody(context),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildResponsiveBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return Center(
        child: Container(
          width: 1200,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: body,
        ),
      );
    } else if (screenWidth > 800) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: body,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      );
    }
  }
}

// Helper class for responsive grid calculations
class ResponsiveHelper {
  static int getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 800) {
      return 3;
    } else if (screenWidth > 600) {
      return 2;
    } else {
      return 1;
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) {
      return 1.2;
    } else {
      return 1.0;
    }
  }

  static double getCardSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) {
      return 20.0;
    } else {
      return 16.0;
    }
  }
}