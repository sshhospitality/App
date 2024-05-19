import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import 'home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    color: Color.fromARGB(255, 216, 204, 238),
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
        width: 500,
      ),
      const SizedBox(height: 24), // Space between the animation and the text
      // First text
      const Text(
        'Welcome to Digi Mess System',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 49, 29, 84), // Text color set to white for better contrast
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
      const SizedBox(height: 50), // Space between the text and the button
      // Login button
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 8, 16.0), // Adjust left padding for left alignment
        child: Align(
          alignment: Alignment.center, // Align the button to the center
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
                fontWeight: FontWeight.bold,
                fontSize: 15, // Make text bold
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
  final width = MediaQuery.of(context).size.width;
  return Scaffold(
    backgroundColor: Colors.white,
    body: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 400,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -40,
                    height: 400,
                    width: width,
                    child: FadeInUp(duration: Duration(seconds: 1), child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.fill
                        )
                      ),
                    )),
                  ),
                  Positioned(
                    height: 400,
                    width: width+20,
                    child: FadeInUp(duration: Duration(milliseconds: 1000), child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/background-2.png'),
                          fit: BoxFit.fill
                        )
                      ),
                    )),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1500), child: Text("Login", style: TextStyle(color: Color.fromRGBO(49, 39, 79, 1), fontWeight: FontWeight.bold, fontSize: 30),)),
                  SizedBox(height: 30,),
                  FadeInUp(duration: Duration(milliseconds: 1700), child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Color.fromRGBO(196, 135, 198, .3)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(196, 135, 198, .3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ]
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(
                              color: Color.fromRGBO(196, 135, 198, .3)
                            ))
                          ),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Email",
                              labelStyle: TextStyle(color: Colors.grey)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                  )),
                  SizedBox(height: 40,),
                  FadeInUp(duration: Duration(milliseconds: 1900), child: MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    color: Color.fromRGBO(49, 39, 79, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    height: 50,
                    child: Center(
                      child: Text("Login", style: TextStyle(color: Colors.white),),
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

}