import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraPreview extends StatelessWidget {
  final CameraController controller;

  const CustomCameraPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1 / controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }
}