part of 'slots_cubit.dart';

sealed class SlotsState {
  const SlotsState._();
  factory SlotsState.initial() = SlotsInitial._;
  factory SlotsState.loading() = SlotsLoading._;
  factory SlotsState.loaded({required List<AvailableSlot> data}) = SlotsLoaded._;
  factory SlotsState.error(String error) = SlotsError._;
}

final class SlotsInitial extends SlotsState {
  const SlotsInitial._() : super._();
}

final class SlotsLoading extends SlotsState {
  const SlotsLoading._() : super._();
}

final class SlotsLoaded extends SlotsState {
  const SlotsLoaded._({required this.data}) : super._();
  final List<AvailableSlot> data;
}

final class SlotsError extends SlotsState {
  const SlotsError._(this.error) : super._();
  final String error;
}
