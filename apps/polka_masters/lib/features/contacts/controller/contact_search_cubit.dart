import 'package:dio/dio.dart';
import 'package:polka_masters/features/contacts/data/contacts_repo.dart';
import 'package:shared/shared.dart';

class ContactSearchCubit extends SearchCubit<Contact> {
  ContactSearchCubit(this.dio, this.repo);

  final Dio dio;
  final ContactsRepository repo;

  @override
  Future<Result<List<Contact>>> query(String query) => repo.searchContacts(query, limit: limit);
}
