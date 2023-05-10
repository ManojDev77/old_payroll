import 'package:flutter/material.dart';
import 'package:pay_lea_task/widgets/shimmer_widget.dart';

class CustomGridView extends StatelessWidget {
  final int? count;
  final double? height;
  final double? width;
  const CustomGridView(
      {super.key,
      required this.count,
      required this.height,
      required this.width});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return const CustomShimmer(
          width: 60,
          height: 60,
          titleOn: true,
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }
}
