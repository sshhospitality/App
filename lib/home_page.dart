import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String userName = '';
  late String college = '';
  late String idNumber = '';
  late String upcomingMeal = '';
  late String mealsCompleted = '';
  late String meal = "";

  @override
  void initState() {
    super.initState();
    fetchData();
    determineMeal();
  }

  void determineMeal() {
    final DateTime now = DateTime.now();
    final int currentHour = now.hour;
    final int currentMinute = now.minute;

    setState(() {
      if (currentHour >= 10 && currentHour < 14) {
        meal = "Lunch";
      } else if (currentHour == 14 && currentMinute <= 29) {
        meal = "Grace1_Lunch";
      } else if (currentHour == 14 && currentMinute <= 59) {
        meal = "Grace2_Lunch";
      } else if (currentHour >= 15 && currentHour < 18) {
        meal = "Snacks";
      } else if (currentHour >= 18 && currentHour < 22) {
        meal = "Dinner";
      } else if (currentHour == 22 && currentMinute <= 29) {
        meal = "Grace1_Dinner";
      } else {
        meal = "Breakfast";
      }
    });
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String sessionCookie = await prefs.getString('token') ?? 'N/A';
      var cookie = 'token=$sessionCookie';
      final response = await http.post(
        Uri.parse(
            "https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/verify/details"),
        headers:<String, String> {
          "cookie": cookie,
        },
        body:{}
      );

      final data = json.decode(response.body);
      print(sessionCookie);
      print(data);
      if (response.statusCode == 200) {
        await prefs.setString('name', data['userInfo']['name']);
        await prefs.setString('college', data['userInfo']['college']);
        setState(() {
          userName = data['userInfo']['name'];
          idNumber = data['userInfo']['userId'];
          college = data['userInfo']['college'];
          mealsCompleted = '${data['transactionsToday']} / 4';
        });
      } else {
        print("Failed to load data, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                InfoTile(title: 'College', content: college),
                InfoTile(title: 'ID Number', content: idNumber),
                InfoTile(title: 'Upcoming Meal', content: meal),
                InfoTile(title: 'Transactions Today', content: mealsCompleted),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Meal Timeline',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            MealTimeline(),
            const SizedBox(height: 24),
            Text(
              'Meal Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PieChartSection(),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String title;
  final String content;

  const InfoTile({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class MealTimeline extends StatelessWidget {
  final meals = [
    {
      'mealName': 'Breakfast',
      'items': ['Bread', 'Butter', 'Eggs', 'Juice'],
      'icon': Icons.breakfast_dining
    },
    {
      'mealName': 'Lunch',
      'items': ['Rice', 'Chicken', 'Vegetables', 'Salad'],
      'icon': Icons.lunch_dining
    },
    {
      'mealName': 'Snacks',
      'items': ['Samosa', 'Tea', 'Biscuits'],
      'icon': Icons.fastfood
    },
    {
      'mealName': 'Dinner',
      'items': ['Chapati', 'Dal', 'Paneer', 'Rice'],
      'icon': Icons.dinner_dining
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: meals.map((meal) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(meal['icon'] as IconData, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['mealName'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (meal['items'] as List<String>).map((item) {
                          return Chip(
                            label: Text(item),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PieChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Breakfast": 5,
      "Lunch": 3,
      "Snacks": 2,
      "Dinner": 4,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PieChart(
          dataMap: dataMap,
          chartType: ChartType.ring,
          chartRadius: MediaQuery.of(context).size.width / 3,
          ringStrokeWidth: 32,
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: false,
            showChartValuesOutside: false,
          ),
        ),
      ),
    );
  }
}
