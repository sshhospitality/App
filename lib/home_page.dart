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
  bool _isPollVisible = false;
  List<Map<String, dynamic>> _polls = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    determineMeal();
    fetchPolls();
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
          headers: <String, String>{
            "cookie": cookie,
          },
          body: {});

      final data = json.decode(response.body);
      print(sessionCookie);
      print(data);
      if (response.statusCode == 200) {
        await prefs.setString('name', data['userInfo']['name']);
        await prefs.setString('college', data['userInfo']['college']);
        await prefs.setString('phone', data['userInfo']['phone'].toString());
        await prefs.setString(
            'idnumber', data['userInfo']['userId'].toString());
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

  Future<void> fetchPolls() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String sessionCookie = prefs.getString('token') ?? 'N/A';
      var cookie = 'token=$sessionCookie';
      final response = await http.get(
        Uri.parse(
            'https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/poll/poll'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'cookie': cookie,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          _polls = responseData.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load polls');
      }
    } catch (e) {
      print('Error fetching polls: $e');
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
              'Dining Chart for this month',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PieChartSection(),
            const SizedBox(height: 8),
            PollSection(polls: _polls),
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
      color: Colors.lightBlue[50], // Light color for better UI
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

class MealTimeline extends StatefulWidget {
  @override
  _MealTimelineState createState() => _MealTimelineState();
}

class _MealTimelineState extends State<MealTimeline> {
  Map<String, List<dynamic>> meals = {
    'Breakfast': [],
    'Grace1_Lunch': [],
    'Grace2_Lunch': [],
    'Lunch': [],
    'Snacks': [],
    'Dinner': [],
    'Grace_Dinner': [],
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
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
      final List<dynamic> mealdata = json.decode(response.body);
      final data = mealdata[0]['days'];
      final today = DateTime.now();
      final todayName = getDayName(today.weekday);
      final todayMeals = data.firstWhere(
        (day) => day['name'] == todayName,
        orElse: () => [],
      );

      if (todayMeals != null) {
        setState(() {
          for (var meal in todayMeals['meals']) {
            final mealType = meal['type'];
            final items = meal['items'] ?? [];
            final itemList = (items as List<dynamic>)
                .map((item) => {
                      'name': item['name'] ?? '',
                      'category': item['category'] ?? '',
                    })
                .toList();
            meals.putIfAbsent(mealType, () => []);
            meals[mealType]!.addAll(itemList);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load meals');
    }
  }

  String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  IconData getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Snacks':
        return Icons.fastfood;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Color getMealColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.blue[300]!;
      case 'Lunch':
        return Colors.green[300]!;
      case 'Snacks':
        return Colors.orange[300]!;
      case 'Dinner':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircularProgressIndicator()
        : Column(
            children: meals.entries.map((entry) {
              final mealType = entry.key;
              final mealItems = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      getMealIcon(mealType),
                      color: getMealColor(mealType),
                    ),
                    title: Text(
                      mealType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Column(
                    children: mealItems.map<Widget>((item) {
                      final itemName = item['name'];
                      final itemCategory = item['category'];
                      return ListTile(
                        title: Text(
                          itemName,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          itemCategory,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          );
  }
}

class PieChartSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataMap = <String, double>{
      "Breakfast": 5,
      "Lunch": 3,
      "Snacks": 2,
      "Dinner": 4,
    };

    final colorList = <Color>[
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.orange[300]!,
      Colors.red[300]!,
    ];

    return Card(
      color: Colors.lightBlue[50], // Light color for better UI
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 32,
              chartRadius: MediaQuery.of(context).size.width / 2.7,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "Meals",
              legendOptions: const LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendShape: BoxShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PollSection extends StatelessWidget {
  final List<Map<String, dynamic>> polls;

  const PollSection({required this.polls, super.key});

  @override
  Widget build(BuildContext context) {
    if (polls.isEmpty) {
      return const Center(
        child: Text("No polls available."),
      );
    }

    return Column(
      children: [
        Text(
          'Polls',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final poll = polls[index];
            return PollItem(poll: poll);
          },
        ),
      ],
    );
  }
}

class PollItem extends StatelessWidget {
  final Map<String, dynamic> poll;

  const PollItem({required this.poll, super.key});

  @override
  Widget build(BuildContext context) {
    final String pollQuestion = poll['question'] ?? 'No question available';
    final List<dynamic> options = poll['options'] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.lightBlue[50], // Light color for better UI
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pollQuestion,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: options.map((option) {
                final String optionText = option['text'] ?? 'No text';
                return ListTile(
                  title: Text(optionText),
                  leading: Radio(
                    value: optionText,
                    groupValue: poll['selectedOption'],
                    onChanged: (value) {
                      // Implement the logic to handle option selection
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsDropdown extends StatelessWidget {
  final List<String> notifications;

  const NotificationsDropdown({required this.notifications, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: notifications.map((String notification) {
        return DropdownMenuItem<String>(
          value: notification,
          child: Text(notification),
        );
      }).toList(),
      onChanged: (_) {},
      hint: Text('Notifications (${notifications.length})'),
      isExpanded: true,
    );
  }
}
