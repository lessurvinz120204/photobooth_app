import 'package:flutter/material.dart';

class BackgroundCategory {
  final String id;
  final String name;
  final String category; // 'solid', 'gradient', 'pattern'
  final Color? solidColor;
  final List<Color>? gradientColors;
  final String? patternImage;
  final IconData icon;

  BackgroundCategory({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.solidColor,
    this.gradientColors,
    this.patternImage,
  });
}

// Preset photobooth backgrounds
final photoboothBackgrounds = [
  // Solid Colors
  BackgroundCategory(
    id: 'white',
    name: 'White',
    category: 'solid',
    solidColor: Colors.white,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'black',
    name: 'Black',
    category: 'solid',
    solidColor: Colors.black,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'red',
    name: 'Red',
    category: 'solid',
    solidColor: Colors.red,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'blue',
    name: 'Blue',
    category: 'solid',
    solidColor: Colors.blue,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'green',
    name: 'Green',
    category: 'solid',
    solidColor: Colors.green,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'purple',
    name: 'Purple',
    category: 'solid',
    solidColor: Colors.purple,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'pink',
    name: 'Pink',
    category: 'solid',
    solidColor: Colors.pink,
    icon: Icons.square,
  ),
  BackgroundCategory(
    id: 'yellow',
    name: 'Yellow',
    category: 'solid',
    solidColor: Colors.yellow,
    icon: Icons.square,
  ),

  // Gradients
  BackgroundCategory(
    id: 'sunset',
    name: 'Sunset',
    category: 'gradient',
    gradientColors: [Colors.deepOrange, Colors.amber],
    icon: Icons.gradient,
  ),
  BackgroundCategory(
    id: 'ocean',
    name: 'Ocean',
    category: 'gradient',
    gradientColors: [Colors.blue, Colors.cyan],
    icon: Icons.gradient,
  ),
  BackgroundCategory(
    id: 'forest',
    name: 'Forest',
    category: 'gradient',
    gradientColors: [Colors.green, Colors.teal],
    icon: Icons.gradient,
  ),
  BackgroundCategory(
    id: 'twilight',
    name: 'Twilight',
    category: 'gradient',
    gradientColors: [Colors.purple, Colors.indigo],
    icon: Icons.gradient,
  ),
  BackgroundCategory(
    id: 'candy',
    name: 'Candy',
    category: 'gradient',
    gradientColors: [Colors.pink, Colors.purple],
    icon: Icons.gradient,
  ),
];

// Group backgrounds by category
Map<String, List<BackgroundCategory>> getBackgroundsByCategory() {
  final Map<String, List<BackgroundCategory>> grouped = {};
  for (var bg in photoboothBackgrounds) {
    if (!grouped.containsKey(bg.category)) {
      grouped[bg.category] = [];
    }
    grouped[bg.category]!.add(bg);
  }
  return grouped;
}
