import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';

class Grabber extends StatelessWidget {
  const Grabber({super.key, required this.controller, required this.builder});

  final DraggableScrollableController controller;
  final Widget Function(BuildContext context, Widget grabber) builder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Calculate the delta as a ratio of the screen height
        final offset = controller.pixels - details.primaryDelta!;
        controller.jumpTo(controller.pixelsToSize(offset));
      },
      child: Material(color: Colors.transparent, child: builder(context, _buildGrabber(context))),
    );
  }

  Widget _buildGrabber(BuildContext context) => Center(
    child: Container(
      margin: EdgeInsets.all(10),
      width: 36,
      height: 5,
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: BorderRadius.circular(5)),
    ),
  );
}
