import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class ImageUploadWidget extends StatefulWidget {
  const ImageUploadWidget({super.key, required this.onImageSelected, this.label = 'Upload Valid ID'});
  final ValueChanged<File> onImageSelected;
  final String label;

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pick() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;
    final picked = await _picker.pickImage(source: src, imageQuality: 80);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() => _image = file);
    widget.onImageSelected(file);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _pick,
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.chipBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid),
      ),
      child: _image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file, color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                Text(widget.label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                Text('JPG, PNG up to 5MB', style: TextStyle(color: AppColors.textSub, fontSize: 11)),
              ],
            ),
    ),
  );
}
