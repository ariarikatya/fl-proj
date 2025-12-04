import 'package:polka_masters/repos/master_repository.dart';
import 'package:shared/shared.dart';

class ServicesCubit extends DataCubit<Map<Service, bool>> {
  ServicesCubit({required this.repo});

  final MasterRepository repo;

  Future<void> toggleServiceVisibility(int serviceId, bool visible) async {
    await repo.setServiceVisibility(serviceId, visible);
    if (state case DataLoaded(:final data)) {
      emit(DataState.loaded(data..[data.keys.firstWhere((k) => k.id == serviceId)] = visible));
    }
  }

  Future<void> updateService(Service service) async {
    (await repo.updateService(service)).unpack(); // Unpack shows errors to user if there are any
    load();
  }

  Future<void> createService(Service service) async {
    (await repo.createService(service)).unpack();
    load();
  }

  Future<void> deleteService(int serviceId) async {
    (await repo.deleteService(serviceId)).unpack();
    load();
  }

  @override
  Future<Result<Map<Service, bool>>> loadData() => repo.getServices();
}
