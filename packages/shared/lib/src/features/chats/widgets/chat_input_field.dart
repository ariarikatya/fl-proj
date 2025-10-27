import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({super.key, required this.onSubmit, required this.onTyping});

  final void Function(String, {List<String> attachments}) onSubmit;
  final void Function(bool typing) onTyping;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late final _controller = TextEditingController();

  final _attachments = ValueNotifier(<XFile>[]);
  final _loading = ValueNotifier(false);
  late final ValueNotifier<bool> _typingNotifier = ValueNotifier(false)
    ..addListener(() => widget.onTyping(_typingNotifier.value));

  final _stopwatch = Stopwatch();
  static const _typingDelay = Duration(milliseconds: 1200);

  void _onTyping() {
    _typingNotifier.value = true;
    _stopwatch
      ..reset()
      ..start();
    Timer(_typingDelay, () {
      if (mounted && _stopwatch.elapsed > _typingDelay) {
        _onTypingStopped();
      }
    });
  }

  void _onTypingStopped() {
    _typingNotifier.value = false;
    _stopwatch.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _typingNotifier.dispose();
    _attachments.dispose();
    super.dispose();
  }

  _submit(String text) async {
    var attachments = <String>[];
    if (_attachments.value.isNotEmpty) {
      _loading.value = true;
      final upload = blocs.get<ChatsCubit>(context).profileRepository.uploadPhotos;
      final imageUrls = await upload(_attachments.value);
      attachments = imageUrls.unpack()?.values.toList() ?? [];
      _deleteAttachments();
      _loading.value = false;
    }
    widget.onSubmit(text, attachments: attachments);
    _onTypingStopped();
    _controller.clear();
  }

  void _pickAttachmentsFromGallery() async {
    final images = await ImagePicker().pickMultiImage(limit: 10);
    _attachments.value = [..._attachments.value, ...images].take(10).toList();
  }

  void _pickAttachmentsFromCamera() async {
    final cameraPhoto = await ImagePicker().pickImage(source: ImageSource.camera);
    _attachments.value = [..._attachments.value, ?cameraPhoto].take(10).toList();
  }

  void _deleteAttachments() => _attachments.value = [];

  @override
  Widget build(BuildContext context) {
    final prefixIcon = GestureDetector(
      onTap: _pickAttachmentsFromGallery,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: SizedBox(
          height: 32,
          width: 32,
          child: Padding(padding: EdgeInsets.all(6), child: AppIcons.add.icon(context, size: 20)),
        ),
      ),
    );

    final cameraIcon = GestureDetector(
      onTap: _pickAttachmentsFromCamera,
      child: Material(
        color: Colors.transparent,
        child: Padding(padding: EdgeInsets.all(6), child: AppIcons.camera.icon(context, size: 20)),
      ),
    );

    final deleteIcon = GestureDetector(
      onTap: _deleteAttachments,
      child: Padding(padding: EdgeInsets.all(8), child: AppIcons.close.icon(context, size: 24)),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
      color: context.ext.theme.backgroundHover,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _attachments,
            builder: (context, value, child) {
              return value.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                spacing: 8,
                                children: [
                                  for (int i = 0; i < value.length; i++)
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: context.ext.theme.backgroundHover,
                                        borderRadius: BorderRadius.circular(6),
                                        image: DecorationImage(
                                          image: FileImage(File(value[i].path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          deleteIcon,
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
          AppInputTextField(
            controller: _controller,
            onChanged: (_) => _onTyping(),
            onFieldSubmitted: _submit,
            hintText: 'Напиши что-нибудь...',
            prefixIcon: prefixIcon,
            suffixWidth: 80,
            suffixIconBuilder: (uploadBtn) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                cameraIcon,
                ValueListenableBuilder(
                  valueListenable: _loading,
                  builder: (context, value, child) {
                    return value
                        ? Container(
                            margin: EdgeInsets.all(12),
                            child: LoadingIndicator(constraints: BoxConstraints.tight(const Size(24, 24))),
                          )
                        : uploadBtn;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
