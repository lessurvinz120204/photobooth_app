import 'package:flutter/material.dart';
import '../models/photo_session.dart';
import '../models/background_category.dart';
import 'capture_screen.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedGridCount = 4;
  String selectedBackground = 'white';
  bool useFrontCamera = false;

  final List<GridOption> gridOptions = [
    GridOption(count: 4, rows: 2, cols: 2, label: "2x2"),
    GridOption(count: 6, rows: 2, cols: 3, label: "2x3"),
    GridOption(count: 8, rows: 2, cols: 4, label: "2x4"),
    GridOption(count: 10, rows: 2, cols: 5, label: "2x5"),
    GridOption(count: 12, rows: 2, cols: 6, label: "2x6"),
  ];

  void _startPhotobooth() async {
    await FirebaseService.signInAnonymously();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CaptureScreen(
            session: PhotoSession(
              gridCount: selectedGridCount,
              backgroundCategory: selectedBackground,
              useFrontCamera: useFrontCamera,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundsByCategory = getBackgroundsByCategory();
    final selectedBg = photoboothBackgrounds.firstWhere(
      (b) => b.id == selectedBackground,
      orElse: () => photoboothBackgrounds[0],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Text(
                    "📸 DIY Photobooth",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Grid Selection Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Grid Layout",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: gridOptions.map((option) {
                          final isSelected = selectedGridCount == option.count;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedGridCount = option.count),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.cyan
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.cyan
                                      : Colors.white38,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    option.label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${option.count} photos",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.black54
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Background Selection Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Background",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Background categories tabs
                      DefaultTabController(
                        length: backgroundsByCategory.length,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: Colors.cyan,
                              unselectedLabelColor: Colors.white70,
                              indicatorColor: Colors.cyan,
                              tabs: backgroundsByCategory.keys
                                  .map((category) => Tab(
                                        text: category == 'solid'
                                            ? 'Solid'
                                            : 'Gradient',
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 100,
                              child: TabBarView(
                                children:
                                    backgroundsByCategory.entries.map((entry) {
                                  return GridView.builder(
                                    scrollDirection: Axis.horizontal,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: entry.value.length,
                                    itemBuilder: (ctx, i) {
                                      final bg = entry.value[i];
                                      final isSelected =
                                          selectedBackground == bg.id;
                                      return GestureDetector(
                                        onTap: () => setState(
                                          () => selectedBackground = bg.id,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.cyan
                                                  : Colors.white30,
                                              width: isSelected ? 3 : 1,
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: bg.solidColor,
                                              gradient: bg.gradientColors !=
                                                      null
                                                  ? LinearGradient(
                                                      colors:
                                                          bg.gradientColors!,
                                                    )
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                bg.name,
                                                style: TextStyle(
                                                  color: bg.id == 'white'
                                                      ? Colors.black87
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Camera Selection
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Use Front Camera",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Switch(
                        value: useFrontCamera,
                        onChanged: (value) =>
                            setState(() => useFrontCamera = value),
                        activeColor: Colors.cyan,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Start Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startPhotobooth,
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text(
                      "Start Photobooth Session",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridOption {
  final int count;
  final int rows;
  final int cols;
  final String label;

  GridOption({
    required this.count,
    required this.rows,
    required this.cols,
    required this.label,
  });
}