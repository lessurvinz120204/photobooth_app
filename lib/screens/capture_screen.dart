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

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller!.initialize().then((_) => setState(() {}));
  }

  Future<void> _takePhoto() async {
    if (capturedImages.length < widget.session.gridCount) {
      final image = await _controller!.takePicture();
      setState(() => capturedImages.add(image));

      if (capturedImages.length == widget.session.gridCount) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => PreviewScreen(images: capturedImages, session: widget.session)
        ));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: Column(
              children: [
                Text("Photo ${capturedImages.length + 1} of ${widget.session.gridCount}"),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _takePhoto,
                  child: const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.camera_alt, color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}