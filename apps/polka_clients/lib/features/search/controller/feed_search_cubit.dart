import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';

// TODO: Refactor for SearchCubit<Master>
class FeedSearchCubit extends Cubit<FeedSearchState> {
  FeedSearchCubit() : super(FeedSearchState.initial());

  final clientRepo = Dependencies().clientRepository;
  bool get isLoading => state is FeedSearchLoading;

  void search(String query, SearchFilter? filter) async {
    if (isLoading) return;

    emit(FeedSearchState.loading());
    final result = await clientRepo.searchMasters(query, filter);
    safeEmit(
      result.when(
        ok: (data) => FeedSearchState.loaded(data: data),
        err: (e, st) => FeedSearchState.error(parseError(e, st)),
      ),
    );
  }
}

sealed class FeedSearchState {
  const FeedSearchState._();
  factory FeedSearchState.initial() = FeedSearchInitial._;
  factory FeedSearchState.loading() = FeedSearchLoading._;
  factory FeedSearchState.loaded({required List<Master> data}) = FeedSearchLoaded._;
  factory FeedSearchState.error(String error) = FeedSearchError._;
}

final class FeedSearchInitial extends FeedSearchState {
  const FeedSearchInitial._() : super._();
}

final class FeedSearchLoading extends FeedSearchState {
  const FeedSearchLoading._() : super._();
}

final class FeedSearchLoaded extends FeedSearchState {
  const FeedSearchLoaded._({required this.data}) : super._();
  final List<Master> data;
}

final class FeedSearchError extends FeedSearchState {
  const FeedSearchError._(this.error) : super._();
  final String error;
}
