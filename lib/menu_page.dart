import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'day_menu_screen.dart';

class MenuPage extends StatefulWidget {
  MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Set<String> availableDays = {};
  Map<String, dynamic> dayMenuData = {}; // Map to store menu data for each day
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableDays();
  }

  Future<void> fetchAvailableDays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String sessionCookie = prefs.getString('token') ?? 'N/A';
    var cookie = 'token=$sessionCookie';
    final response = await http.post(
      Uri.parse(
          'https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/menu/list'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': cookie,
      },
      body: jsonEncode(<String, String>{}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (var user in data) {
        for (var day in user['days']) {
          availableDays.add(day['name']);
          dayMenuData[day['name']] = day; // Store day data in the map
        }
      }

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load days');
    }
  }

  void showNoMenuAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Menu Available'),
          content: Text('There is no menu available for today.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void handleDayTap(String day) {
    if (availableDays.contains(day)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DayMenuScreen(day: day, menuData: dayMenuData[day]),
        ),
      );
    } else {
      showNoMenuAlert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: days.asMap().entries.map((entry) {
                  int index = entry.key;
                  String day = entry.value;
                  return Positioned(
                    top: index * 70.0,
                    left: index % 2 == 0 ? 0 : 20.0,
                    right: index % 2 == 0 ? 20.0 : 0,
                    child: GestureDetector(
                      onTap: () => handleDayTap(day),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.8),
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
