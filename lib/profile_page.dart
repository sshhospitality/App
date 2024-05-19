import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'N/A';
  String college = 'N/A';
  String email = 'N/A';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'N/A';
      college = prefs.getString('college') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/hero1.jpg'), // Ensure this path is correct
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                college,
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Call the backend logout endpoint
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final String sessionCookie = prefs.getString('token') ?? '';
                    final response = await http.post(
                      Uri.parse(
                          'https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/auth/logout'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'cookie': 'token=$sessionCookie',
                      },
                    );

                    if (response.statusCode == 200) {
                      // Logout successful, clear local data
                      await prefs.clear();
                      // Navigate to the OnboardingScreen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OnboardingScreen()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      // Handle backend logout failure
                      print('Backend logout failed');
                    }
                  } catch (e) {
                    // Handle exceptions
                    print('Error during logout: $e');
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
