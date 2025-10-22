import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:shared/shared.dart';

part 'slots_state.dart';

class SlotsCubit extends Cubit<SlotsState> {
  SlotsCubit(int masterId, int serviceId) : super(SlotsState.initial()) {
    getSlots(masterId, serviceId);
  }

  final _clientRepo = Dependencies().clientRepository;

  void getSlots(int masterId, int serviceId) async {
    emit(SlotsState.loading());
    final result = await _clientRepo.getSlots(masterId, serviceId);
    safeEmit(
      result.when(
        ok: (data) => SlotsState.loaded(data: data),
        err: (error, st) => SlotsState.error(parseError(error, st)),
      ),
    );
  }
}
