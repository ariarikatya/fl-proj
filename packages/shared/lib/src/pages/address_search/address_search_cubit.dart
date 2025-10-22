import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/models/address.dart';
import 'package:shared/src/utils.dart';

class AddressSearchCubit extends Cubit<AddressSearchState> {
  AddressSearchCubit(this.dio) : super(AddressSearchState.initial()) {
    logger.info('Created AddressSearchCubit');
  }

  @override
  Future<void> close() {
    logger.warning('Closed AddressSearchCubit');
    return super.close();
  }

  final Dio dio;
  bool _isLoading = false;

  static const _throttleDuration = Duration(milliseconds: 300);

  void search(String query) async {
    if (_isLoading) return;

    if (query.trim().isEmpty) return emit(AddressSearchState.loaded(data: []));

    try {
      _isLoading = true;
      final response = await dio.get('/address/suggestions', queryParameters: {'q': query});
      final addresses = parseJsonList(
        (response.data['suggestions'] as List? ?? []).cast<Map<String, dynamic>>(),
        Address.fromJson,
      ).take(10).toList();
      emit(AddressSearchState.loaded(data: addresses));
      await Future.delayed(_throttleDuration);
    } catch (e, st) {
      logger.handle(e, st);
      emit(AddressSearchState.error(parseError(e, st)));
    } finally {
      _isLoading = false;
    }
  }
}

sealed class AddressSearchState {
  const AddressSearchState._();
  factory AddressSearchState.initial() = AddressSearchInitial._;
  factory AddressSearchState.loading() = AddressSearchLoading._;
  factory AddressSearchState.loaded({required List<Address> data}) = AddressSearchLoaded._;
  factory AddressSearchState.error(String error) = AddressSearchError._;
}

final class AddressSearchInitial extends AddressSearchState {
  const AddressSearchInitial._() : super._();
}

final class AddressSearchLoading extends AddressSearchState {
  const AddressSearchLoading._() : super._();
}

final class AddressSearchLoaded extends AddressSearchState {
  const AddressSearchLoaded._({required this.data}) : super._();
  final List<Address> data;
}

final class AddressSearchError extends AddressSearchState {
  const AddressSearchError._(this.error) : super._();
  final String error;
}
