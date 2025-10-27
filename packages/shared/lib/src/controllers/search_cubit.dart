import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

abstract class SearchCubit<T extends Object> extends Cubit<SearchState<T>> {
  SearchCubit({this.throttleDuration = const Duration(milliseconds: 300), this.limit = 10})
    : super(SearchState.initial()) {
    logger.info('Created SearchCubit<$T>');
  }

  @override
  Future<void> close() {
    logger.info('Closed SearchCubit<$T>');
    return super.close();
  }

  final Duration throttleDuration;
  final int limit;

  void bindController(TextEditingController controller) {
    controller.addListener(() {
      if (controller.text.trim().isNotEmpty) {
        search(controller.text.trim());
      }
      // Assuming the user has finished typing; Anyway this will be throttled in `search` method
      Timer(Duration(milliseconds: 500), () {
        if (!isClosed) search(controller.text.trim());
      });
    });
    search(controller.text.trim());
  }

  Future<Result<List<T>>> query(String query);

  bool _isLoading = false;

  void search(String $query) async {
    if (_isLoading) return;

    if ($query.trim().isEmpty) return emit(SearchState.initial());

    try {
      _isLoading = true;
      final data = await query($query);
      emit(
        data.when(
          ok: (data) => SearchState.loaded(data: data),
          err: (e, st) => SearchState.error(parseError(e, st)),
        ),
      );
      await Future.delayed(throttleDuration);
    } catch (e, st) {
      emit(SearchState.error(parseError(e, st)));
    } finally {
      _isLoading = false;
    }
  }
}

sealed class SearchState<T extends Object> {
  const SearchState._();
  factory SearchState.initial() = SearchInitial._;
  factory SearchState.loading() = SearchLoading._;
  factory SearchState.loaded({required List<T> data}) = SearchLoaded._;
  factory SearchState.error(String error) = SearchError._;
}

final class SearchInitial<T extends Object> extends SearchState<T> {
  const SearchInitial._() : super._();
}

final class SearchLoading<T extends Object> extends SearchState<T> {
  const SearchLoading._() : super._();
}

final class SearchLoaded<T extends Object> extends SearchState<T> {
  const SearchLoaded._({required this.data}) : super._();
  final List<T> data;
}

final class SearchError<T extends Object> extends SearchState<T> {
  const SearchError._(this.error) : super._();
  final String error;
}
