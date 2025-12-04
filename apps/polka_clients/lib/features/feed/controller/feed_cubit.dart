import 'package:polka_clients/repositories/client_repository.dart';
import 'package:shared/shared.dart';

class FeedCubit extends PaginationCubit<Master> {
  FeedCubit(this.repo);
  final ClientRepository repo;

  @override
  Future<Result<List<Master>>> loadItems(int page, int limit) =>
      repo.getMastersFeed(limit: limit, offset: (page - 1) * limit);
}
