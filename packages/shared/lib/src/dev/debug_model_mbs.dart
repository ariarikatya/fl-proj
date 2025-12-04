import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';
import 'package:shared/src/widgets/grabber.dart';
import 'package:shared/src/widgets/json_widget.dart';

Future<void> showDebugModel(BuildContext context, JsonEquatable model) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DebugModelBottomSheet(model),
  );
}

class _DebugModelBottomSheet extends StatefulWidget {
  const _DebugModelBottomSheet(this.model);

  final JsonEquatable model;

  @override
  State<_DebugModelBottomSheet> createState() => _DebugModelBottomSheetState();
}

class _DebugModelBottomSheetState extends State<_DebugModelBottomSheet> {
  final _controller = DraggableScrollableController();
  late final model = widget.model;

  bool _showInitialJson = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      controller: _controller,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.ext.colors.white[100],
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Grabber(controller: _controller, builder: (context, grabber) => grabber),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(24),
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      children: [
                        Expanded(child: AppText(model.debugName, style: AppTextStyles.headingSmall)),
                        if (model.json != null)
                          AppTextButton.small(
                            text: 'Show ${_showInitialJson ? 'parsed' : 'initial'} JSON',
                            onTap: () => setState(() => _showInitialJson = !_showInitialJson),
                          )
                        else
                          AppText('No API JSON', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    JsonWidget(json: _showInitialJson && model.json != null ? model.json! : model.toJson()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
