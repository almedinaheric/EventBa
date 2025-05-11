import 'package:flutter/material.dart';

enum AppBarType {
  titleLeftIconRight,
  titleCenterIconRight,
  iconsSideTitleCenter,
}

class MasterScreenWidget extends StatefulWidget {
  final Widget child;
  final AppBarType appBarType;
  final String? title;
  final VoidCallback? onRightButtonPressed;
  final VoidCallback? onLeftButtonPressed;
  final IconData? rightIcon;
  final IconData? leftIcon;

  const MasterScreenWidget({
    required this.child,
    this.appBarType = AppBarType.titleLeftIconRight,
    this.title,
    this.onRightButtonPressed,
    this.onLeftButtonPressed,
    this.rightIcon,
    this.leftIcon,
    super.key,
  });

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == 2) return; // '+' button is custom handled
    setState(() => _selectedIndex = index);
    print(index);
    // Add navigation logic here Navigator.pushNamed()
  }

  PreferredSizeWidget _buildAppBar() {
    switch (widget.appBarType) {
      case AppBarType.titleLeftIconRight:
        return AppBar(
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("EventBa"),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: widget.onRightButtonPressed,
            ),
          ],
        );
      case AppBarType.titleCenterIconRight:
        return AppBar(
          centerTitle: true,
          title: Text(widget.title ?? ''),
          actions: [
            IconButton(
              icon: Icon(widget.rightIcon ?? Icons.more_vert),
              onPressed: widget.onRightButtonPressed,
            ),
          ],
        );
      case AppBarType.iconsSideTitleCenter:
        return AppBar(
          leading: IconButton(
            icon: Icon(widget.leftIcon ?? Icons.menu),
            onPressed: widget.onLeftButtonPressed,
          ),
          centerTitle: true,
          title: Text(widget.title ?? ''),
          actions: [
            IconButton(
              icon: Icon(widget.rightIcon ?? Icons.settings),
              onPressed: widget.onRightButtonPressed,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.favorite, 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.confirmation_number, 3),
              _buildNavItem(Icons.person, 4),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle '+' tap
          print("FAB tapped");
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onBottomNavTap(index),
      icon: Icon(
        icon,
        color: isSelected ? Colors.deepPurple : Colors.grey,
      ),
    );
  }
}
