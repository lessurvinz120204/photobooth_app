import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/photo_session.dart';
import 'preview_screen.dart';
import '../main.dart';

class CaptureScreen extends StatefulWidget {
  final PhotoSession session;
  const CaptureScreen({super.key, required this.session});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  List<XFile> capturedImages = [];
  bool _useFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    final cameraIndex = _useFrontCamera
        ? cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front)
        : cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);

    final selectedCamera = cameraIndex >= 0 ? cameras[cameraIndex] : cameras[0];

    _controller = CameraController(selectedCamera, ResolutionPreset.high);
    _controller!.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _toggleCamera() async {
    await _controller?.dispose();
    setState(() => _useFrontCamera = !_useFrontCamera);
    _initCamera();
  }

  Future<void> _takePhoto() async {
    if (capturedImages.length < widget.session.gridCount) {
      final image = await _controller!.takePicture();
      setState(() => capturedImages.add(image));

      if (capturedImages.length == widget.session.gridCount) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PreviewScreen(
              images: capturedImages,
              session: widget.session,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          // Top bar with camera toggle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Photo ${capturedImages.length + 1} of ${widget.session.gridCount}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _useFrontCamera ? Icons.camera_front : Icons.camera_rear,
                      color: Colors.white,
                    ),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),
          // Bottom capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _takePhoto,
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, color: Colors.black, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}