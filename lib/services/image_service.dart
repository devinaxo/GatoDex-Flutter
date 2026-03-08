import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:ui' as ui;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  static const int _maxDimension = 800;

  Future<String> get _imageDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(path.join(appDir.path, 'images'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    return imgDir.path;
  }

  Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestGalleryPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return null;
    return _compressAndSave(File(image.path));
  }

  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null) return null;
    return _compressAndSave(File(image.path));
  }

  /// Compresses and saves the image to the app's images directory.
  /// Uses dart:ui for decoding/re-encoding at reduced quality and size.
  Future<File> _compressAndSave(File sourceFile) async {
    final bytes = await sourceFile.readAsBytes();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _maxDimension,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    // If the image height is still too large after width constraint,
    // re-decode with height constraint instead
    ui.Image finalImage = image;
    if (image.height > _maxDimension) {
      final ui.Codec codec2 = await ui.instantiateImageCodec(
        bytes,
        targetHeight: _maxDimension,
      );
      final ui.FrameInfo frame2 = await codec2.getNextFrame();
      finalImage = frame2.image;
    }

    final ByteData? byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      // Fallback: just copy the original
      return _saveRaw(sourceFile);
    }

    final compressedBytes = byteData.buffer.asUint8List();

    final dir = await _imageDirectory;
    final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = File(path.join(dir, fileName));
    await savedFile.writeAsBytes(compressedBytes, flush: true);

    return savedFile;
  }

  Future<File> _saveRaw(File source) async {
    final dir = await _imageDirectory;
    final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return source.copy(path.join(dir, fileName));
  }

  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.startsWith('assets/')) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
