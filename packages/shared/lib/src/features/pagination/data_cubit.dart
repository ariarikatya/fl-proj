import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/src/extensions/bloc.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

abstract class DataCubit<T> extends Cubit<DataState<T>> {
  DataCubit() : super(DataState.initial()) {
    load();
  }

  Future<Result<T>> loadData();

  /// In cases where you just need to watch for data and do not need to react to states
  T? get data {
    if (state case DataLoaded<T>(:final data)) return data;
    return null;
  }

  /// Loads data using the implementation of [loadData]
  /// `silent` parameter disables loading animation (ignores emitting LoadingState)
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(DataState.loading());

    final result = await loadData();
    safeEmit(result.when(ok: (data) => DataState.loaded(data), err: (err, st) => DataState.error(parseError(err, st))));
  }
}

sealed class DataState<T> {
  const DataState._();
  factory DataState.initial() = DataInitial._;
  factory DataState.loading() = DataLoading._;
  factory DataState.loaded(T data) = DataLoaded._;
  factory DataState.error(String error) = DataError._;
}

final class DataInitial<T> extends DataState<T> {
  const DataInitial._() : super._();
}

final class DataLoading<T> extends DataState<T> {
  const DataLoading._() : super._();
}

final class DataLoaded<T> extends DataState<T> {
  const DataLoaded._(this.data) : super._();
  final T data;
}

final class DataError<T> extends DataState<T> {
  const DataError._(this.error) : super._();
  final String error;
}
