import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:camera/camera.dart';
import '../models/photo_session.dart';
import '../services/database_service.dart';
import '../core/constants.dart';

class PreviewScreen extends StatefulWidget {
  final List<XFile> images;
  final PhotoSession session;
  const PreviewScreen({super.key, required this.images, required this.session});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final DatabaseService _dbService = DatabaseService();
  Color _selectedBg = Colors.white;
  bool _isSaving = false;

  Future<void> _exportBooth() async {
    setState(() => _isSaving = true);
    
    final Uint8List? rawBytes = await _screenshotController.capture();
    if (rawBytes != null) {
      // Compress to fit under Firestore 1MB limit
      final Uint8List compressed = await FlutterImageCompress.compressWithList(
        rawBytes, minHeight: 1080, minWidth: 1080, quality: 70
      );

      // Upload (Base64) then Save locally then Delete from DB
      String? docId = await _dbService.saveTemporaryImage(compressed);
      
      // Save to gallery - need to write to temp file first
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/booth_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(compressed);
      await Gal.putImage(tempFile.path);
      
      if (docId != null) await _dbService.deleteImage(docId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved to Gallery!")));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customize Booth")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color: _selectedBg,
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.session.cols,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.images.length,
                    itemBuilder: (ctx, i) => Image.file(File(widget.images[i].path), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: AppConstants.bgColors.map((c) => IconButton(
                icon: Icon(Icons.circle, color: c, size: 30),
                onPressed: () => setState(() => _selectedBg = c),
              )).toList(),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _exportBooth,
            icon: _isSaving ? const CircularProgressIndicator() : const Icon(Icons.download),
            label: const Text("Save & Finish"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}