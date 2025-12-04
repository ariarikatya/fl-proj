import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.constraints, this.value});

  final BoxConstraints? constraints;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      constraints: constraints,
      color: context.ext.colors.pink[500],
      strokeCap: StrokeCap.round,
      backgroundColor: context.ext.colors.pink[100],
      value: value,
    );
  }
}
