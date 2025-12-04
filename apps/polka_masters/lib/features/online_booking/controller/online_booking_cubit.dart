import 'package:polka_masters/repos/online_booking_repository.dart';
import 'package:shared/shared.dart';

final class OnlineBookingCubit extends DataCubit<OnlineBookingConfig> {
  OnlineBookingCubit(this.repo);
  final OnlineBookingRepository repo;

  @override
  Future<Result<OnlineBookingConfig>> loadData() => repo.getPublicLinkConfig();

  void changeVisibility(OnlineBookingVisibility visibility) async {
    await repo.setPublicLinkVisibility(visibility);
    load(silent: true);
  }

  void toggleNightStop() async {
    await repo.toggleNightStop();
    load(silent: true);
  }
}
