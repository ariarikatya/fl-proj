import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:shared/shared.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesState(favorites: {})) {
    loadFavorites();
  }

  final favoritesRepo = Dependencies().favoritesRepo;

  void like(int masterId) async {
    emit(state._load(masterId));
    final result = await favoritesRepo.addFavoriteMaster(masterId);
    result.maybeWhen(
      ok: (data) => emit(state._add(masterId)),
      err: (e, st) {
        handleError(e, st);
        emit(state._remove(masterId));
      },
    );
  }

  void unlike(int masterId) async {
    emit(state._load(masterId));
    final result = await favoritesRepo.removeFavoriteMaster(masterId);
    result.maybeWhen(
      ok: (data) => emit(state._remove(masterId)),
      err: (e, st) {
        handleError(e, st);
        emit(state._add(masterId));
      },
    );
  }

  void loadFavorites() async {
    final result = await favoritesRepo.getFavoriteMasters();
    result.maybeWhen(
      ok: (data) => emit(
        FavoritesState(
          favorites: Map.fromIterable(data.map((e) => e.id), value: (e) => FavoriteStatus.liked),
        ),
      ),
      err: (e, st) => handleError(e, st, false),
    );
  }
}

enum FavoriteStatus { liked, loading, notLiked }

final class FavoritesState extends Equatable {
  const FavoritesState({required this.favorites});
  final Map<int, FavoriteStatus> favorites;

  FavoritesState _load(int masterId) =>
      FavoritesState(favorites: Map.from(favorites)..[masterId] = FavoriteStatus.loading);

  FavoritesState _add(int masterId) =>
      FavoritesState(favorites: Map.from(favorites)..[masterId] = FavoriteStatus.liked);

  FavoritesState _remove(int masterId) =>
      FavoritesState(favorites: Map.from(favorites)..remove(masterId));

  FavoriteStatus statusOf(int masterId) => favorites[masterId] ?? FavoriteStatus.notLiked;

  @override
  List<Object?> get props => [favorites];
}
