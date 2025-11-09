import 'package:polka_clients/repositories/client_repository.dart';
import 'package:shared/shared.dart';

class SlotsCubit extends DataCubit<List<AvailableSlot>> {
  SlotsCubit({required this.repo, required this.masterId, required this.serviceId});

  final ClientRepository repo;
  final int masterId, serviceId;

  @override
  Future<Result<List<AvailableSlot>>> loadData() => repo.getSlots(masterId, serviceId);
}
