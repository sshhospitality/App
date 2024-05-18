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
  List<String> _notifications = [
    "Notification 1",
    "Notification 2",
    "Notification 3",
    "Notification 4",
    "Notification 5",
    "Notification 6",
  ];

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
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: _toggleNotificationVisibility,
          ),
        ],
        leading: SizedBox(width: 5),
      ),
      body: Stack(
        children: [
          _widgetOptions[_selectedIndex],
          if (_isNotificationVisible)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 233, 254, 249),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                              color: Colors.grey,
                              height: 1,
                            ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _notifications[index],
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        },
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
