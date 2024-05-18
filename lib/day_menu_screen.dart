import 'package:flutter/material.dart';

class DayMenuScreen extends StatelessWidget {
  final String day;
  const DayMenuScreen({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealSections = {
      'Breakfast': [
        {'image': 'assets/breakfast_veg.jpg', 'caption': 'Pancakes with syrup', 'isVeg': true},
        {'image': 'assets/breakfast_non_veg.jpg', 'caption': 'Omelette with veggies', 'isVeg': false},
        {'image': 'assets/breakfast_veg.jpg', 'caption': 'Omelette with veggies', 'isVeg': true},
        {'image': 'assets/breakfast_non_veg.jpg', 'caption': 'Omelette with veggies', 'isVeg': false},
      ],
      'Lunch': [
        {'image': 'assets/lunch_veg.jpg', 'caption': 'Grilled chicken with salad', 'isVeg': false},
        {'image': 'assets/lunch_veg.jpg', 'caption': 'Vegetable pasta', 'isVeg': true},
      ],
      'Snacks': [
        {'image': 'assets/snacks_veg.jpg', 'caption': 'Fruit smoothie', 'isVeg': true},
        {'image': 'assets/snacks_veg.jpg', 'caption': 'Granola bar', 'isVeg': true},
      ],
      'Dinner': [
        {'image': 'assets/dinner_non_veg.jpg', 'caption': 'Steak with mashed potatoes', 'isVeg': false},
        {'image': 'assets/dinner_veg.jpg', 'caption': 'Vegetable stir-fry', 'isVeg': true},
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('$day\'s Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: mealSections.keys.map((mealType) {
          final items = mealSections[mealType]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  mealType,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
              SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 160,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                          child: Image.asset(
                                            item['image'] as String, // Cast to String
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item['caption'] as String, // Cast to String
                                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                        color: item['isVeg'] as bool ? Colors.green : Colors.red, // Cast to bool
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                        ),
                                      ),
                                      child: Icon(
                                        item['isVeg'] as bool ? Icons.eco : Icons.auto_awesome, // Cast to bool
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
