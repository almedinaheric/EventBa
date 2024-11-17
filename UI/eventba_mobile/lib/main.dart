import 'package:eventba_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/custom_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventBa',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B7CF6)),
          useMaterial3: true,
          fontFamily: 'Poppins'),
      //home: const MyHomePage(title: 'EventBa'),
      home: const LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Set your desired height
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Transparent to show Container color
            elevation: 0, // Remove AppBar's default elevation
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4776E6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    color: const Color(0xFF363B3E),
                    iconSize: 32.0,
                    onPressed: () {
                      // Add action for the ring bell icon here
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 10),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          backgroundColor: Color(0xFF4776E6),
          elevation: 0,
          onPressed: () => debugPrint("Add Button pressed"),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Color(0xFF4776E6)),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.add,
            size: 40.0,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors
              .white, // Set the background color of the BottomNavigationBar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, -4), // Shadow is cast upwards
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 32.0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, size: 32.0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(), // Invisible widget for the middle icon
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num_outlined, size: 32.0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 32.0),
              label: '',
            ),
          ],
          selectedItemColor: const Color(0xFF4776E6), // Selected icon color
          unselectedItemColor: const Color(0xFF363B3E), // Unselected icon color
          type: BottomNavigationBarType.fixed, // Keeps all items visible
        ),
      ),
    );
  }
}
