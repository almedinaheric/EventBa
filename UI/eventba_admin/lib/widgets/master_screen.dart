import 'package:eventba_admin/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterScreen extends StatefulWidget {
  final Widget? child;
  final String? title;
  final bool hideAppBar;

  const MasterScreen({
    this.child,
    this.title,
    this.hideAppBar = false,
    super.key,
  });

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  //late AuthProvider _authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar
          ? AppBar(
        title: Text(widget.title ?? ""),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _drawProfileIcon(),
          ),
        ],
      )
          : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            widget.child ?? const Placeholder(),
          ],
        ),
      ),
    );
  }

  Widget _drawProfileIcon() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.account_circle_outlined,
        size: 32,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () {
            //_authProvider.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              ModalRoute.withName('LoginScreen'),
            );
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
