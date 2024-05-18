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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => handleDayTap(days[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
