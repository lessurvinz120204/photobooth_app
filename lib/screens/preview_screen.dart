import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:camera/camera.dart';
import '../models/photo_session.dart';
import '../models/background_category.dart';
import '../services/firebase_service.dart';

class PreviewScreen extends StatefulWidget {
  final List<XFile> images;
  final PhotoSession session;
  const PreviewScreen({super.key, required this.images, required this.session});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late BackgroundCategory _selectedBackground;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedBackground = photoboothBackgrounds.firstWhere(
      (b) => b.id == widget.session.backgroundCategory,
      orElse: () => photoboothBackgrounds[0],
    );
  }

  Future<void> _exportBooth() async {
    setState(() => _isSaving = true);

    try {
      final Uint8List? rawBytes = await _screenshotController.capture();
      if (rawBytes != null) {
        // Compress image to reasonable size
        final Uint8List compressed = await FlutterImageCompress.compressWithList(
          rawBytes,
          minHeight: 1080,
          minWidth: 1080,
          quality: 85,
        );

        // Save to gallery first
        final tempDir = Directory.systemTemp;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile =
            File('${tempDir.path}/booth_$timestamp.jpg');
        await tempFile.writeAsBytes(compressed);
        await Gal.putImage(tempFile.path);

        // Upload to Firebase
        final userId = FirebaseService.getCurrentUserId();
        final photoId = await FirebaseService.uploadPhotoBoothImage(
          imageFile: tempFile,
          userId: userId,
          gridCount: widget.session.gridCount,
          rows: widget.session.rows,
          cols: widget.session.cols,
          backgroundCategory: _selectedBackground.id,
          usedFrontCamera: widget.session.useFrontCamera,
        );

        // Clean up temp file
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        if (mounted) {
          if (photoId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✓ Saved to Gallery and Cloud!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✓ Saved to Gallery (Cloud upload pending)"),
                backgroundColor: Colors.orange,
              ),
            );
          }
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Export Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  Decoration _getBackgroundDecoration() {
    if (_selectedBackground.category == 'gradient' &&
        _selectedBackground.gradientColors != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: _selectedBackground.gradientColors!,
        ),
      );
    }
    return BoxDecoration(
      color: _selectedBackground.solidColor ?? Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundsByCategory = getBackgroundsByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customize Your Booth"),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            child: Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    decoration: _getBackgroundDecoration(),
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.session.cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: widget.images.length,
                      itemBuilder: (ctx, i) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(widget.images[i].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Background selection panel
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Solid colors
                    ...backgroundsByCategory['solid']?.map((bg) {
                          final isSelected = _selectedBackground.id == bg.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedBackground = bg),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.cyan
                                      : Colors.white30,
                                  width: isSelected ? 4 : 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: bg.solidColor,
                                child: Text(
                                  bg.name,
                                  style: TextStyle(
                                    color: bg.id == 'white'
                                        ? Colors.black87
                                        : Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }).toList() ??
                        [],
                    const SizedBox(width: 12),
                    // Gradients
                    ...backgroundsByCategory['gradient']?.map((bg) {
                          final isSelected = _selectedBackground.id == bg.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedBackground = bg),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.cyan
                                      : Colors.white30,
                                  width: isSelected ? 4 : 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage: null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: bg.gradientColors!,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      bg.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList() ??
                        [],
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Retake"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _exportBooth,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSaving ? "Saving..." : "Save & Finish"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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