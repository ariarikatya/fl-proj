part of 'search_cubit.dart';

sealed class SearchState {
  const SearchState._();
  factory SearchState.initial() = SearchInitial._;
  factory SearchState.loading() = SearchLoading._;
  factory SearchState.loaded({required List<Master> data}) = SearchLoaded._;
  factory SearchState.error(String error) = SearchError._;
}

final class SearchInitial extends SearchState {
  const SearchInitial._() : super._();
}

final class SearchLoading extends SearchState {
  const SearchLoading._() : super._();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded._({required this.data}) : super._();
  final List<Master> data;
}

final class SearchError extends SearchState {
  const SearchError._(this.error) : super._();
  final String error;
}
