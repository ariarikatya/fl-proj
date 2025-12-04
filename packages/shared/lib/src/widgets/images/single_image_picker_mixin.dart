import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/src/errors.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

typedef PhotoUploadFunction = Future<Result<String>> Function(XFile image);

mixin SingleImagePickerMixin<T extends StatefulWidget> on State<T> {
  String? _imageUrl;
  XFile? _imageFile;
  bool _loading = false;

  bool get loading => _loading;
  bool get hasImage => (_imageUrl != null || _imageFile != null) && !loading;
  bool get canPickImage => !loading && !hasImage;

  String? get initialImageUrl;
  PhotoUploadFunction get upload;
  Function(String? imageUrl) get onImageUpdate;

  @override
  void initState() {
    super.initState();
    _imageUrl = initialImageUrl;
  }

  void pickImage() async {
    if (!canPickImage) return;

    XFile? xfile;
    try {
      xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e, st) {
      return handleError(PhotoPickException(e is PlatformException ? e : null), st);
    }
    if (xfile != null) {
      _imageFile = xfile;
      _loading = true;
      setState(() {});

      final imageUrl = (await upload(xfile)).unpack();
      if (imageUrl != null) {
        onImageUpdate(imageUrl);
        _imageUrl = imageUrl;
      }

      _imageFile = null;
      _loading = false;
      setState(() {});
    }
  }

  void deleteImage() {
    _imageFile = null;
    _imageUrl = null;
    onImageUpdate(null);
    setState(() {});
  }

  ImageProvider? get imageProvider {
    if (_imageUrl != null) {
      return CachedNetworkImageProvider(_imageUrl!);
    } else if (_imageFile != null) {
      return FileImage(File(_imageFile!.path));
    }
    return null;
  }

  Widget? get image {
    if (_imageUrl != null) {
      return CachedNetworkImage(imageUrl: _imageUrl!, fit: BoxFit.cover);
    } else if (_imageFile != null) {
      return Image.file(File(_imageFile!.path), fit: BoxFit.cover);
    }
    return null;
  }
}
