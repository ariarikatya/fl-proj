import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.previousMessageTimestamp});

  final DateTime? previousMessageTimestamp; // Required for displaying day tooltip if necessary
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final textColor = message.isOwnMessage ? context.ext.theme.backgroundDefault : context.ext.theme.textPrimary;

    Widget content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: RichText(
        textWidthBasis: TextWidthBasis.longestLine,
        text: TextSpan(
          style: AppTextStyles.bodyLarge.copyWith(color: textColor),
          children: [
            TextSpan(text: message.content),
            WidgetSpan(child: SizedBox(width: 6)),
            WidgetSpan(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isOwnMessage)
                    switch (message.status) {
                      'sent' => AppIcons.check.icon(context, size: 20, color: textColor),
                      'read' => AppIcons.checkDouble.icon(context, size: 20, color: textColor),
                      _ => SizedBox.shrink(),
                    },
                  AppText(
                    message.sentAt.toLocal().formatTimeOnly(),
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: textColor),
                  ),
                ],
              ),
              alignment: PlaceholderAlignment.bottom,
            ),
          ],
        ),
      ),
    );

    // If there are attachments, show preview (first image)
    content = _AttachmentsWrapper(message: message, child: content);

    // Build the message bubble
    Widget widget = Row(
      mainAxisAlignment: message.isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (message.isOwnMessage) Flexible(child: SizedBox.shrink()),
        Flexible(
          flex: 8,
          child: DebugWidget(
            model: message,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ClipPath(
                clipper: BubbleClipper(clipRightBottom: !message.isOwnMessage, clipLeftBottom: message.isOwnMessage),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                  color: message.isOwnMessage ? context.ext.theme.buttonPrimary : context.ext.theme.backgroundHover,
                  child: content,
                ),
              ),
            ),
          ),
        ),
        if (!message.isOwnMessage) Flexible(child: SizedBox.shrink()),
      ],
    );

    // Add day tooltip if day changed
    if (previousMessageTimestamp == null || !DateUtils.isSameDay(previousMessageTimestamp, message.sentAt)) {
      widget = Column(
        spacing: 8,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8, 2.5, 8, 2.5),
            decoration: BoxDecoration(color: context.ext.theme.accentLight, borderRadius: BorderRadius.circular(100)),
            child: AppText(message.sentAt.formatDateRelative(), style: AppTextStyles.bodyMedium),
          ),
          widget,
        ],
      );
    }

    return widget;
  }
}

class _AttachmentsWrapper extends StatelessWidget {
  const _AttachmentsWrapper({required this.message, required this.child});

  final ChatMessage message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (message.attachments.isNotEmpty) {
      final imageProvider = message.attachments.length == 1
          ? SingleImageProvider(CachedNetworkImageProvider(message.attachments.first))
          : ChatMultiImageProvider([for (var url in message.attachments) CachedNetworkImageProvider(url)]);

      Widget attachment = GestureDetector(
        onTap: () => showImageViewerPager(
          context,
          imageProvider,
          immersive: false,
          useSafeArea: true,
          doubleTapZoomable: true,
          swipeDismissible: true,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          backgroundColor: Colors.transparent,
        ),
        child: ImageClipped(imageUrl: message.fileUrl!, borderRadius: 12, height: 300),
      );

      // Show count of attachments if there are more than one
      if (message.attachments.length > 1) {
        attachment = Stack(
          children: [
            attachment,
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: context.ext.theme.accentLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.ext.theme.accent, width: 1),
                ),
                child: AppText(
                  '+ ${message.attachments.length - 1}',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.ext.theme.accent),
                ),
              ),
            ),
          ],
        );
      }

      content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [attachment, content]);
    }

    return content;
  }
}

class BubbleClipper extends CustomClipper<Path> {
  final bool clipRightBottom;
  final bool clipLeftBottom;

  BubbleClipper({super.reclip, required this.clipRightBottom, required this.clipLeftBottom});

  @override
  Path getClip(Size size) {
    const radius = 16.0;

    final path = Path();

    // Start top-left
    path.moveTo(radius, 0);

    // Top Right
    path.lineTo(size.width - radius * 2, 0);
    path.quadraticBezierTo(size.width - radius, 0, size.width - radius, radius);

    // Bottom Right
    path.lineTo(size.width - radius, size.height - radius);
    if (clipRightBottom) {
      path.quadraticBezierTo(size.width - radius, size.height, size.width - radius * 2, size.height);
    } else {
      path.quadraticBezierTo(size.width - radius, size.height, size.width, size.height);
      path.lineTo(size.width, size.height);
    }

    // Bottom Left
    path.lineTo(radius * 2, size.height);
    if (clipLeftBottom) {
      path.quadraticBezierTo(radius, size.height, radius, size.height - radius);
    } else {
      path.lineTo(0, size.height);
      path.lineTo(0, size.height);
      path.quadraticBezierTo(radius, size.height, radius, size.height - radius);
    }

    // Top Left
    path.lineTo(radius, radius);
    path.quadraticBezierTo(radius, 0, radius * 2, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
