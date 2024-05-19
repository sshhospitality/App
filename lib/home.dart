import 'package:flutter/material.dart';
import 'home_page.dart';
import 'feedback_page.dart';
import 'qr_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'shimmer.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;
  bool _isNotificationVisible = false;
  bool _isPageLoading = false;

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
  }

  Future<List<Map<String, String>>> fetchNotifications() async {
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
        return responseData.map<Map<String, String>>((notification) {
          return {
            'title': notification['title'] ?? 'No title',
            'description': notification['message'] ?? 'No description',
            'createdAt': notification['createdAt'] ?? 'No date',
          };
        }).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Handle the error appropriately in your app (e.g., show a dialog or a snackbar)
      return [];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _isPageLoading = true;
      _selectedIndex = index;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isPageLoading = false;
      });
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
      body: _isPageLoading
          ? const Center(child: ShimmerLoading())
          : Stack(
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FutureBuilder<List<Map<String, String>>>(
                        future: fetchNotifications(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                                child: Text('No notifications'));
                          } else {
                            final notifications = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: notifications.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      final createdAtString =
                                          notification['createdAt'];
                                      DateTime createdAt;
                                      if (createdAtString != null) {
                                        createdAt =
                                            DateTime.parse(createdAtString);
                                      } else {
                                        createdAt = DateTime
                                            .now(); // Fallback date if null
                                      }

                                      final timeAgo = timeago.format(createdAt);
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons
                                                  .notification_important, // Replace with your desired icon
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                                width:
                                                    8.0), // Space between icon and text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    notification['title'] ??
                                                        'No title',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    notification[
                                                            'description'] ??
                                                        'No description',
                                                    style: TextStyle(
                                                        color: Colors.black87),
                                                  ),
                                                  SizedBox(height: 4.0),
                                                  Text(
                                                    timeAgo,
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                        },
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
