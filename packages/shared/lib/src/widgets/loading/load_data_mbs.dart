import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/mbs/mbs_base.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/error_widget.dart';
import 'package:shared/src/widgets/loading/load_data_page.dart';
import 'package:shared/src/widgets/loading/loading_indicator.dart';

class LoadDataMbs<T extends Object> extends StatefulWidget {
  const LoadDataMbs({
    super.key,
    required this.future,
    required this.builder,
    this.onErrorBehavior = OnErrorBehavior.pop,
    this.showGrabber = true,
    this.expandContent = false,
  });

  final Future<Result<T>> Function() future;
  final Widget Function(T data) builder;
  final OnErrorBehavior onErrorBehavior;
  final bool showGrabber;
  final bool expandContent;

  @override
  State<LoadDataMbs<T>> createState() => _LoadDataMbsState<T>();
}

class _LoadDataMbsState<T extends Object> extends State<LoadDataMbs<T>> {
  late final _future = widget.future();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data?.isErr == true) {
          if (widget.onErrorBehavior == OnErrorBehavior.pop) {
            WidgetsBinding.instance.addPostFrameCallback((_) => context.ext.pop());
          }
        }

        return MbsBase(
          showGrabber: widget.showGrabber,
          expandContent: widget.expandContent,
          child: AnimatedSize(
            duration: Durations.medium1,
            curve: Curves.easeInOut,
            child: switch (snapshot) {
              AsyncSnapshot<Result<T>>(data: ResultSuccess(:final data)) => widget.builder(data),
              AsyncSnapshot<Result<T>>(data: ResultError(:final err)) => AppErrorWidget(error: parseError(err)),
              _ => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: const Center(child: LoadingIndicator()),
              ),
            },
          ),
        );
      },
    );
  }
}
