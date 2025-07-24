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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        automaticallyImplyLeading: showBackButton,
        bottom: bottomAppBar,
        toolbarHeight: 60,
        title: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  'EventBa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF4776E6),
                  ),
                ),
              ),
            ),
            // Center: Dynamic title
            if(title != 'EventBa')
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
        actions: appBarActions ??
            [
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: _buildAdminDropdown(context),
              ),
            ],
      ),

      body: SafeArea(
        child: _buildResponsiveBody(context),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildAdminDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        _handleMenuSelection(context, value);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Sign Out',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Admin Admin',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_2_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 20,
            color: Colors.grey[600],
          ),
        ],
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'signout':
        _showSignOutDialog(context);
        break;
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performSignOut(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _performSignOut(BuildContext context) {
    // Clear any stored authentication tokens
    // Example: await AuthService.signOut();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully signed out'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to login screen and clear navigation stack
    // Replace this with your actual login screen navigation
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // Replace with your login route
          (route) => false,
    );

    // If you don't have named routes, you can use:
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => LoginScreen()),
    //   (route) => false,
    // );
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