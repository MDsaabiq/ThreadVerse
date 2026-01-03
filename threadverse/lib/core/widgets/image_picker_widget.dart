import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Image picker widget with upload UI
class ImagePickerWidget extends StatefulWidget {
  final Function(XFile) onImageSelected;
  final String? initialImageUrl;
  final String label;
  final bool isCircle;

  const ImagePickerWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.label = 'Upload Image',
    this.isCircle = false,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedBytes;
  bool _loading = false;

  Future<void> _pickImage() async {
    try {
      setState(() => _loading = true);
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        _selectedBytes = bytes;
        widget.onImageSelected(pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
      _selectedBytes != null || (widget.initialImageUrl?.isNotEmpty ?? false);

    if (widget.isCircle) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _selectedBytes != null
              ? MemoryImage(_selectedBytes!)
                : (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty
                    ? NetworkImage(widget.initialImageUrl!)
                    : null),
            child: (_selectedBytes == null &&
                    (widget.initialImageUrl == null ||
                        widget.initialImageUrl!.isEmpty))
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: theme.disabledColor,
                  )
                : null,
          ),
          FloatingActionButton.small(
            onPressed: _loading ? null : _pickImage,
            backgroundColor: theme.primaryColor,
            child: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.scaffoldBackgroundColor,
                      ),
                    ),
                  )
                : const Icon(Icons.camera_alt),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _loading ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.dividerColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: hasImage ? null : theme.primaryColor.withOpacity(0.05),
        ),
        child: _loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _selectedBytes != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        _selectedBytes!,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: FloatingActionButton.small(
                          onPressed: _pickImage,
                          backgroundColor: theme.primaryColor,
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  )
                : (widget.initialImageUrl != null &&
                        widget.initialImageUrl!.isNotEmpty)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.initialImageUrl!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: FloatingActionButton.small(
                              onPressed: _pickImage,
                              backgroundColor: theme.primaryColor,
                              child: const Icon(Icons.edit),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select image from gallery',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
