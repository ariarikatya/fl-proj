import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/models/city.dart';
import 'package:shared/src/utils.dart';

class CitySearchCubit extends Cubit<CitySearchState> {
  CitySearchCubit(this.dio) : super(CitySearchState.initial()) {
    logger.info('Created CitySearchCubit');
  }

  @override
  Future<void> close() {
    logger.info('Closed CitySearchCubit');
    return super.close();
  }

  final Dio dio;
  bool _isLoading = false;

  void search(String query) async {
    if (_isLoading) return;

    if (query.trim().isEmpty) return emit(CitySearchState.loaded(data: []));

    try {
      _isLoading = true;
      final response = await dio.get('/cities/suggestions', queryParameters: {'q': query});
      final cities = (response.data['suggestions'] as List)
          .map((e) => City.fromJson(e))
          .take(10)
          .toList();
      emit(CitySearchState.loaded(data: cities));
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e, st) {
      emit(CitySearchState.error(parseError(e, st)));
    } finally {
      _isLoading = false;
    }
  }
}

sealed class CitySearchState {
  const CitySearchState._();
  factory CitySearchState.initial() = CitySearchInitial._;
  factory CitySearchState.loading() = CitySearchLoading._;
  factory CitySearchState.loaded({required List<City> data}) = CitySearchLoaded._;
  factory CitySearchState.error([String? error]) = CitySearchError._;
}

final class CitySearchInitial extends CitySearchState {
  const CitySearchInitial._() : super._();
}

final class CitySearchLoading extends CitySearchState {
  const CitySearchLoading._() : super._();
}

final class CitySearchLoaded extends CitySearchState {
  const CitySearchLoaded._({required this.data}) : super._();
  final List<City> data;
}

final class CitySearchError extends CitySearchState {
  const CitySearchError._([this.error]) : super._();
  final String? error;
}
