import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            height: 60.0,
            width: double.infinity,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8.0),
          ),
          // Image shimmer
          Container(
            height: 200.0,
            width: double.infinity,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8.0),
          ),
          // List shimmer
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Number of shimmer items
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title shimmer
                      Container(
                        height: 20.0,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8.0),
                      // Subtitle shimmer
                      Container(
                        height: 20.0,
                        width: 150.0,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8.0),
                      // Image shimmer
                      Container(
                        height: 100.0,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
