import 'package:flutter/material.dart';
import 'home_page.dart';
import 'feedback_page.dart';
import 'qr_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;
  bool _isNotificationVisible = false;

  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const FeedbackPage(),
    const QRPage(),
    MenuPage(),
    const ProfilePage(),
  ];

  final List<String> _appBarTitles = <String>[
    'Home',
    'Feedback',
    'QR',
    'Menu',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleNotificationVisibility() {
    setState(() {
      _isNotificationVisible = !_isNotificationVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _toggleNotificationVisibility,
          ),
        ],leading: SizedBox(width: 5),
      ),
      body: Stack(
        children: [
          _widgetOptions[_selectedIndex],
          if (_isNotificationVisible)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 200,
                height: 200,
                color: Colors.deepPurple,
                child: ListView(
                  children: const [
                    ListTile(
                      title: Text(
                        'Notification 1',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Notification 2',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Notification 3',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
