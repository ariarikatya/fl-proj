import 'package:polka_masters/features/contacts/data/contacts_repo.dart';
import 'package:shared/shared.dart';

class ContactSearchCubit extends SearchCubit<Contact> {
  ContactSearchCubit(this.repo, {this.group}) : super(allowEmptySearch: true);

  final ContactsRepository repo;
  final ContactGroup? group;

  @override
  Future<Result<List<Contact>>> query(String query) => repo.searchContacts(query: query, category: group, limit: limit);
}

class BlacklistContactSearchCubit extends SearchCubit<Contact> {
  BlacklistContactSearchCubit(this.repo) : super(allowEmptySearch: true);

  final ContactsRepository repo;

  @override
  Future<Result<List<Contact>>> query(String query) => repo.searchBlacklist(query: query, limit: limit);
}
