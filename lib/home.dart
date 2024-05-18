import 'package:flutter/material.dart';
import 'home_page.dart';
import 'feedback_page.dart';
import 'qr_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;
  bool _isNotificationVisible = false;
  List<Map<String, String>> _notifications = [];

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

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String sessionCookie = prefs.getString('token') ?? 'N/A';
      var cookie = 'token=$sessionCookie';
      final response = await http.post(
        Uri.parse(
            'https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/notification/get'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _notifications =
              responseData.map<Map<String, String>>((notification) {
            return {
              'title': notification['title'] ?? 'No title',
              'description': notification['message'] ?? 'No description',
              'createdAt': notification['createdAt'] ?? 'No date',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Handle the error appropriately in your app (e.g., show a dialog or a snackbar)
    }
  }

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
                            final notification = _notifications[index];
                            return ListTile(
                              title: Text(
                                notification['title'] ?? 'No title',
                                style: TextStyle(color: Colors.black),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification['description'] ??
                                        'No description',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  Text(
                                    notification['createdAt'] ?? 'No date',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            );
                          }),
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
