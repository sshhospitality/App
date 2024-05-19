import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';


void main() {
  // Set the background color of the notification bar to white
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // Background color of the status bar
    statusBarIconBrightness: Brightness.dark, // Dark icons for the status bar
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digi Mess System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle( // Set the background color of the notification bar
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: AnimatedSplashScreen(
        splash: Image.asset("assets/splash.jpg"),
        nextScreen: const OnboardingScreen(),
        splashTransition: SplashTransition.slideTransition,
        pageTransitionType: PageTransitionType.bottomToTop,
        duration: 1500,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.deepPurple.withOpacity(0.8), // Darker shade of purple
        Colors.purple.withOpacity(0.6), // Lighter shade of purple
      ],
    ),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 24.0), // Add horizontal padding
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align contents to the left
    children: [
      const SizedBox(height: 100), // Add space from top
      // Lottie animation
      Lottie.asset(
        'assets/onboarding.json',
        height: 300,
        width: 300,
      ),
      const SizedBox(height: 24), // Space between the animation and the text
      // First text
      const Text(
        'Welcome to Digi Mess System',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple, // Text color set to white for better contrast
        ),
      ),
      const SizedBox(height: 8), // Add a small gap
      // Second text
      const Text(
        'Experience the convenience of managing your meals digitally.',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white, // Text color set to white for better contrast
        ),
      ),
      const SizedBox(height: 30), // Space between the text and the button
      // Login button
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 8, 16.0), // Adjust left padding for left alignment
        child: Align(
          alignment: Alignment.centerLeft, // Align the button to the left
          child: ElevatedButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login(title: 'Digi Mess')),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white, // Set text color to white
                fontWeight: FontWeight.bold, // Make text bold
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),

    );
  }
}


class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/auth/login'), // Replace with your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var cookie = response.headers['set-cookie']!;

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _loadDetails(responseBody, cookie);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainHomePage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void _loadDetails(Map<String, dynamic> responseBody, String cookie) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', responseBody['user']['email']);
    await prefs.setString('person', responseBody['user']['person']);
    await prefs.setString('token', responseBody['token']);
    await prefs.setString('_id', responseBody['user']['_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Login into Digi Mess',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.deepPurple),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}