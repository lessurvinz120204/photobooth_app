import 'package:flutter/material.dart';
import '../models/photo_session.dart';

class GridOverlay extends StatelessWidget {
  final PhotoSession session;

  const GridOverlay({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: session.cols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: session.gridCount,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}