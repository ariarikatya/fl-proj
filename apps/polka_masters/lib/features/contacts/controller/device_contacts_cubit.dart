import 'package:fast_contacts/fast_contacts.dart' as fast_contacts;
import 'package:shared/shared.dart';

class DeviceContactsCubit extends SearchCubit<fast_contacts.Contact> {
  DeviceContactsCubit() : super(allowEmptySearch: true);

  List<fast_contacts.Contact>? _contacts;

  // @override
  // Future<Result<List<fast_contacts.Contact>>> loadItems(int page, int limit) async {
  //   _contacts ??= await fast_contacts.FastContacts.getAllContacts();
  //   return Result.ok(_contacts!.skip((page - 1) * limit).take(limit).toList());
  // }

  @override
  Future<Result<List<fast_contacts.Contact>>> query(String query) async {
    _contacts ??= await fast_contacts.FastContacts.getAllContacts();
    final searchResult = _contacts!.where(
      (c) =>
          c.displayName.toLowerCase().contains(query.toLowerCase()) ||
          c.phones.any((phone) => matchesPhone(phone.number, query)),
    );
    return Result.ok(searchResult.take(limit).toList());
  }

  bool matchesPhone(String phone, String query) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final cleanQuery = query.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanQuery.isEmpty || cleanPhone.isEmpty) return false;
    return cleanPhone.contains(cleanQuery);
  }
}
