import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/images/image_clipped.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key, required this.imageUrls, this.width, this.height, this.withIndicator = true});

  final List<String> imageUrls;
  final double? width, height;
  final bool withIndicator;

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  late final images = widget.imageUrls.take(4).toList();

  final _controller = PageController(
    initialPage: 0,
    viewportFraction: 0.999, // viewportFraction is less than 1 so that next photo is loaded preemptively
  );
  final _selectedIndex = ValueNotifier(0);

  @override
  void dispose() {
    _controller.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => _selectedIndex.value = index,
            itemCount: images.length,
            itemBuilder: (context, index) =>
                ImageClipped(imageUrl: images[index], width: widget.width, height: widget.height),
          ),
        ),
        SizedBox(height: 4),
        if (images.length > 1)
          ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder: (context, value, child) {
              return Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    for (var i = 0; i < images.length; i++)
                      Container(
                        width: value == i ? 16 : 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: value == i ? context.ext.colors.pink[500] : context.ext.colors.white[200],
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                  ],
                ),
              );
            },
          )
        else
          SizedBox(height: 4),
      ],
    );
  }
}
