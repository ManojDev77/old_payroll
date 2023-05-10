import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final bool? titleOn;
  const CustomShimmer(
      {super.key,
      required this.titleOn,
      required this.height,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height,
              width: width,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          if (titleOn!)
            const SizedBox(
              height: 10,
            ),
          if (titleOn!)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Center(
                child: Container(
                  width: 50.0,
                  height: 10.0,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
