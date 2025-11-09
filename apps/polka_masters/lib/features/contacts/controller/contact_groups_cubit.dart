import 'package:polka_masters/features/contacts/data/contacts_repo.dart';
import 'package:shared/shared.dart';

class ContactGroupsCubit extends DataCubit<Map<ContactGroup, int>> with SocketListenerMixin {
  ContactGroupsCubit(this.repo);

  final ContactsRepository repo;

  @override
  Future<Result<Map<ContactGroup, int>>> loadData() => repo.getCategoriesInfo();

  @override
  void onSocketsMessage(json) {
    if (json case <String, Object?>{'type': 'appointment_update', 'update_type': String _}) {
      logger.debug('Contacts group update');
      load();
    }
  }

  @override
  void onSocketsReconnect() => load();
}
