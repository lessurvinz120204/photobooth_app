import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'core/theme.dart';

List<CameraDescription> cameras = [];

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // On web, cameras might not be available immediately
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint("Camera error: $e");
    }
    runApp(const PhotoboothApp());
  } catch (e) {
    debugPrint("Firebase init error: $e");
    // Run the app anyway so you don't get a white screen
    runApp(const PhotoboothApp()); 
  }
}
class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key}); // This is the 'constructor' the error is looking for
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}