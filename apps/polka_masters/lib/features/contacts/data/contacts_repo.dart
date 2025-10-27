import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

sealed class ContactsRepository {
  Future<Result<Contact>> createContact(String name, String phone);
  Future<Result<List<Contact>>> searchContacts(String query, {int limit = 10});
}

final class RestContactsRepository extends ContactsRepository {
  RestContactsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Contact>> createContact(String name, String phone) => tryCatch(() async {
    final response = await dio.post('/clients/add', data: {'name': name, 'phone': phone});
    return Contact.fromJson(response.data);
  });

  @override
  Future<Result<List<Contact>>> searchContacts(String query, {int limit = 10}) => tryCatch(() async {
    final response = await dio.get('/clients/search', queryParameters: {'query': query, 'limit': limit});
    return parseJsonList(response.data['clients'], Contact.fromJson);
  });
}
