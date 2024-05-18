import 'package:flutter/material.dart';

class DayMenuScreen extends StatelessWidget {
  final String day;
  final dynamic menuData; // Use the appropriate type for menu data

  DayMenuScreen({required this.day, required this.menuData});

  // Function to determine the correct image based on meal type and category
  String getImage(String mealType, String category) {
    final mealTypeLower = mealType.toLowerCase();
    final categoryLower = category.toLowerCase();

    if (mealTypeLower.contains('breakfast')) {
      return categoryLower == 'veg'
          ? 'assets/breakfast_veg.jpg'
          : 'assets/breakfast_non_veg.jpg';
    } else if (mealTypeLower.contains('lunch')) {
      return categoryLower == 'veg'
          ? 'assets/lunch_veg.jpg'
          : 'assets/lunch_non_veg.jpg';
    } else if (mealTypeLower.contains('snacks')) {
      return categoryLower == 'veg'
          ? 'assets/snacks_veg.jpg'
          : 'assets/snacks_non_veg.jpg';
    } else if (mealTypeLower.contains('dinner')) {
      return categoryLower == 'veg'
          ? 'assets/dinner_veg.jpg'
          : 'assets/dinner_non_veg.jpg';
    } else {
      return 'assets/default.jpg'; // Fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$day\'s Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: menuData['meals'].map<Widget>((meal) {
          final String mealType = meal['type'];
          final List<dynamic> items = meal['items'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  mealType,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
              ),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 160,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16)),
                                          child: Image.asset(
                                            getImage(
                                                mealType, item['category']),
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item['name'],
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: item['category'] == 'Veg'
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                        ),
                                      ),
                                      child: Icon(
                                        item['category'] == 'Veg'
                                            ? Icons.eco
                                            : Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add some space between sections
            ],
          );
        }).toList(),
      ),
    );
  }
}
