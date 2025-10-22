import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/widgets/app_page.dart';
import 'package:shared/src/widgets/appbars.dart';
import 'package:shared/src/widgets/error_widget.dart';
import 'package:shared/src/widgets/loading/loading_indicator.dart';

enum OnErrorBehavior { pop, showErrorPage }

class LoadDataPage<T extends Object> extends StatefulWidget {
  const LoadDataPage({
    super.key,
    required this.future,
    required this.builder,
    this.onErrorBehavior = OnErrorBehavior.pop,
    this.title,
  });

  final Future<Result<T>> Function() future;
  final Widget Function(T data) builder;
  final OnErrorBehavior onErrorBehavior;
  final String? title;

  @override
  State<LoadDataPage<T>> createState() => _LoadDataPageState<T>();
}

class _LoadDataPageState<T extends Object> extends State<LoadDataPage<T>> {
  late final _future = widget.future();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isOk) {
          return widget.builder((snapshot.data! as ResultSuccess).data);
        }
        if (snapshot.hasError || snapshot.data?.isErr == true) {
          if (widget.onErrorBehavior == OnErrorBehavior.pop) {
            Timer(Duration.zero, () => Navigator.pop(context));
          } else {
            return Center(child: const AppErrorWidget(error: 'Произошла ошибка'));
          }
        }
        return AppPage(
          appBar: CustomAppBar(title: widget.title ?? ''),
          child: Center(child: LoadingIndicator()),
        );
      },
    );
  }
}
