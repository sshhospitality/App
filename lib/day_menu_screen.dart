import 'package:flutter/material.dart';

class DayMenuScreen extends StatelessWidget {
  final String day;
  const DayMenuScreen({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mealSections = {
      'Breakfast': [
        {'image': 'assets/breakfast1.jpg', 'caption': 'Pancakes with syrup'},
        {'image': 'assets/breakfast1.jpg', 'caption': 'Omelette with veggies'},
        {'image': 'assets/breakfast1.jpg', 'caption': 'Omelette with veggies'},
        {'image': 'assets/breakfast1.jpg', 'caption': 'Omelette with veggies'},
      ],
      'Lunch': [
        {'image': 'assets/lunch1.jpg', 'caption': 'Grilled chicken with salad'},
        {'image': 'assets/lunch1.jpg', 'caption': 'Vegetable pasta'},
      ],
      'Snacks': [
        {'image': 'assets/snacks1.jpg', 'caption': 'Fruit smoothie'},
        {'image': 'assets/snacks1.jpg', 'caption': 'Granola bar'},
      ],
      'Dinner': [
        {'image': 'assets/dinner1.jpg', 'caption': 'Steak with mashed potatoes'},
        {'image': 'assets/dinner1.jpg', 'caption': 'Vegetable stir-fry'},
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
                height: 180,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 160,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.asset(
                                    item['image']!,
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item['caption']!,
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                              ],
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
