import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

sealed class ContactsRepository {
  Future<Result<Contact>> createContact(Contact contact);
  Future<Result<List<Contact>>> searchContacts({String? query, ContactGroup? category, int page = 1, int limit = 10});
  Future<Result<List<Contact>>> searchBlacklist({String? query, int page = 1, int limit = 10});
  Future<Result<Map<ContactGroup, int>>> getCategoriesInfo();
  Future<Result<ContactInfo>> getContactInfo(int contactId);
  Future<Result<void>> blockContact(int contactId);
  Future<Result<void>> unblockContact(int contactId);
  Future<Result<void>> updateContact(
    int contactId, {
    String? name,
    String? city,
    DateTime? birthday,
    String? email,
    String? notes,
  });
}

final class RestContactsRepository extends ContactsRepository {
  RestContactsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Contact>> createContact(Contact contact) => tryCatch(() async {
    final response = await dio.post('/master/contacts', data: contact.toJson()..remove('id'));
    return Contact.fromJson(response.data['data']);
  });

  @override
  Future<Result<List<Contact>>> searchContacts({String? query, ContactGroup? category, int page = 1, int limit = 10}) =>
      tryCatch(() async {
        final params = {'query': ?query, 'category': ?category?.toJson(), 'page': page, 'limit': limit};
        final response = await dio.get('/master/contacts/search', queryParameters: params);
        return parseJsonList(response.data['data'], Contact.fromJson);
      });

  @override
  Future<Result<List<Contact>>> searchBlacklist({String? query, int page = 1, int limit = 10}) => tryCatch(() async {
    final params = {'query': ?query, 'page': page, 'limit': limit};
    final response = await dio.get('/master/contacts/blacklist/search', queryParameters: params);
    return parseJsonList(response.data['data'], Contact.fromJson);
  });

  @override
  Future<Result<Map<ContactGroup, int>>> getCategoriesInfo() => tryCatch(() async {
    final response = await dio.get('/master/contacts/analytics/categories');
    return {
      for (final item in response.data['data'])
        ContactGroup.fromJson(item['category']) ?? ContactGroup.neW: item['count'],
    };
  });

  @override
  Future<Result<ContactInfo>> getContactInfo(int contactId) => tryCatch(() async {
    final response = await dio.get('/master/contacts/$contactId');
    return ContactInfo.fromJson(response.data['data']);
  });

  @override
  Future<Result<void>> updateContact(
    int contactId, {
    String? name,
    String? city,
    DateTime? birthday,
    String? email,
    String? notes,
  }) => tryCatch(() async {
    await dio.put(
      '/master/contacts/$contactId',
      data: {'name': ?name, 'city': ?city, 'birthday': ?birthday?.toJson(), 'email': ?email, 'notes': ?notes},
    );
  });

  @override
  Future<Result<void>> blockContact(int contactId) => tryCatch(() => dio.post('/master/contacts/$contactId/block'));

  @override
  Future<Result<void>> unblockContact(int contactId) => tryCatch(() => dio.post('/master/contacts/$contactId/unblock'));
}
