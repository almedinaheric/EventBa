import 'package:eventba_mobile/screens/event_creation_screen.dart';
import 'package:eventba_mobile/screens/favorite_events_screen.dart';
import 'package:eventba_mobile/screens/home_screen.dart';
import 'package:eventba_mobile/screens/notifications_screen.dart';
import 'package:eventba_mobile/screens/profile_screen.dart';
import 'package:eventba_mobile/screens/tickets_screen.dart';
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
  final bool showBottomNavBar;
  final int initialIndex;

  const MasterScreenWidget({
    required this.child,
    this.appBarType = AppBarType.titleLeftIconRight,
    this.title,
    this.onRightButtonPressed,
    this.onLeftButtonPressed,
    this.rightIcon,
    this.leftIcon,
    this.showBottomNavBar = true,
    this.initialIndex = 0,
    super.key,
  });

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    Widget screen;
    switch (index) {
      case -1:
        return;
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const FavoriteEventsScreen();
        break;
      case 2:
        screen = const EventCreationScreen();
        break;
      case 3:
        screen = const TicketsScreen();
        break;
      case 4:
        screen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => MasterScreenWidget(
          appBarType: index == 0
              ? AppBarType.titleLeftIconRight
              : AppBarType.titleCenterIconRight,
          title: index == 0 ? null : _getTitleForIndex(index),
          showBottomNavBar: true,
          initialIndex: index,
          child: screen,
        ),
        transitionDuration: Duration.zero,
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 1:
        return 'Favorite Events';
      case 2:
        return 'Create Event';
      case 3:
        return 'Tickets';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  PreferredSizeWidget _buildAppBar() {
    switch (widget.appBarType) {
      case AppBarType.titleLeftIconRight:
        return AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: const Row(
            children: [
              SizedBox(width: 24),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF120E5B),
                  ),
                  children: [
                    TextSpan(text: 'Event'),
                    TextSpan(
                      text: 'Ba',
                      style: TextStyle(color: Color(0xFF4776E6)),
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const NotificationsScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        );

      case AppBarType.titleCenterIconRight:
        return AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            widget.title ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            if (widget.rightIcon != null)
              IconButton(
                icon: Icon(widget.rightIcon),
                onPressed: widget.onRightButtonPressed,
              ),
          ],
        );
      case AppBarType.iconsSideTitleCenter:
        return AppBar(
          leading: IconButton(
            icon: Icon(widget.leftIcon ?? Icons.arrow_back),
            onPressed:
            widget.onLeftButtonPressed ?? () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(widget.title ?? '',
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          actions: [
            if (widget.rightIcon != null)
              IconButton(
                icon: Icon(widget.rightIcon),
                onPressed: widget.onRightButtonPressed,
              ),
          ],
        );
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onBottomNavTap(index),
      icon: Icon(
        icon,
        size: 32,
        color: isSelected ? const Color(0xFF4776E6) : const Color(0xFF363B3E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.child,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: widget.showBottomNavBar
          ? BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 0),
              _buildNavItem(Icons.favorite_border, 1),
              const SizedBox(width: 0), // for FAB spacing
              _buildNavItem(Icons.confirmation_num_outlined, 3),
              _buildNavItem(Icons.person_outlined, 4),
            ],
          ),
        ),
      )
          : null,
      floatingActionButton: widget.showBottomNavBar
          ? FloatingActionButton(
        onPressed: () => _onBottomNavTap(2),
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFF4776E6),
        elevation: 6,
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
