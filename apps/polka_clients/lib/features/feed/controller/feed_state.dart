part of 'feed_cubit.dart';

@immutable
sealed class FeedState {
  const FeedState._();
  const factory FeedState.initial() = FeedInitial._;
  const factory FeedState.loading() = FeedLoading._;
  const factory FeedState.loaded(List<Master> data) = FeedLoaded._;
  const factory FeedState.error(String error) = FeedError._;
}

final class FeedInitial extends FeedState {
  const FeedInitial._() : super._();
}

final class FeedLoading extends FeedState {
  const FeedLoading._() : super._();
}

final class FeedLoaded extends FeedState {
  const FeedLoaded._(this.data) : super._();
  final List<Master> data;
}

final class FeedError extends FeedState {
  const FeedError._(this.error) : super._();
  final String error;
}
