import 'package:flutter/material.dart';

class DayMenuScreen extends StatelessWidget {
  final String day;
  const DayMenuScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    // Dummy data for each meal section
    final mealSections = {
      'Breakfast': [
        {'image': 'assets/breakfast1.jpg', 'caption': 'Pancakes with syrup'},
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
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  mealType,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ),
              const SizedBox(height: 10),
              ...items.map((item) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item['image']!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      item['caption']!,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20), // Add some space between sections
            ],
          );
        }).toList(),
      ),
    );
  }
}
