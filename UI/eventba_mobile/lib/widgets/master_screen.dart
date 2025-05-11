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
          automaticallyImplyLeading: false,
          titleSpacing: 0, // ensures title can start from the left
          title: const Row(
            children: [
              SizedBox(width: 24), // manual padding from the left
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 18, 14, 91),
                  ),
                  children: [
                    TextSpan(text: 'Event'),
                    TextSpan(
                      text: 'Ba',
                      style: TextStyle(
                        color: Color.fromARGB(255, 49, 101, 223),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.notifications_outlined),
              onPressed: widget.onRightButtonPressed,
            ),
            const SizedBox(width: 16), // manual padding from the left
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
      body: widget.child, // Delegate body content to the child screen
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.favorite_border, 1),
              const SizedBox(width: 0),
              _buildNavItem(Icons.confirmation_num_outlined, 3),
              _buildNavItem(Icons.person_outlined, 4),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle '+' tap
          print("FAB tapped");
        },
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF5B7CF6),
        elevation: 6,
        child: const Icon(Icons.add),
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
        size: 32,
        color: isSelected ? const Color(0xFF5B7CF6) : Colors.grey,
      ),
    );
  }
}
