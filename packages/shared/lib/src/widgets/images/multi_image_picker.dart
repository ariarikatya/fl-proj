import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/src/widgets/images/image_picker_widget.dart';

class MultiImagePickerWidget extends StatefulWidget {
  const MultiImagePickerWidget({super.key, required this.count, required this.onImagesChanged, this.layoutBuilder});

  final int count;
  final Function(List<XFile>) onImagesChanged;
  final Widget Function(List<Widget> widgets)? layoutBuilder;

  @override
  State<MultiImagePickerWidget> createState() => _MultiImagePickerWidgetState();
}

class _MultiImagePickerWidgetState extends State<MultiImagePickerWidget> {
  late final _images = ValueNotifier<List<XFile>>([])..addListener(_onImagesChanged);

  void _onImagesChanged() => widget.onImagesChanged(_images.value);

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage(limit: widget.count);
    _images.value = [..._images.value, ...images].take(widget.count).toList();
  }

  @override
  void dispose() {
    _images.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _images,
      builder: (context, images, child) {
        return widget.layoutBuilder?.call(_imageWidgets(images)) ??
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              scrollDirection: Axis.horizontal,
              child: Row(spacing: 8, children: _imageWidgets(images)),
            );
      },
    );
  }

  List<Widget> _imageWidgets(List<XFile> images) => [
    for (var i = 0; i < widget.count; i++)
      ImagePickerWidget(
        onPickImage: _pickImages,
        onDelete: () {
          final value = images.length > i ? images[i] : null;
          if (value != null) {
            _images.value = List.from(images..remove(value));
          }
        },
        image: images.length > i ? images[i] : null,
      ),
  ];
}
