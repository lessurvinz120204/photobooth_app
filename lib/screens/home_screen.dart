import 'package:flutter/material.dart';
import '../models/photo_session.dart';
import 'capture_screen.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("DIY Photobooth", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _buildButton(context, "Classic 1x1", 1),
            _buildButton(context, "Double 2x2", 4),
            _buildButton(context, "Studio 3x3", 9),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
        onPressed: () async {
          await FirebaseService.signInAnonymously();
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => CaptureScreen(session: PhotoSession(gridCount: count))
            ));
          }
        },
        child: Text(title),
      ),
    );
  }
}