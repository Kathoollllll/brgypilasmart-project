import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  // Compress image and convert to Base64 string for Firestore storage
  static Future<String?> toBase64(File file) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 40,       // low quality = small size
        minWidth: 600,
        minHeight: 400,
      );
      if (compressed == null) return null;
      return base64Encode(compressed);
    } catch (e) {
      return null;
    }
  }

  // Convert Base64 string back to image bytes for display
  static List<int>? fromBase64(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (e) {
      return null;
    }
  }
}