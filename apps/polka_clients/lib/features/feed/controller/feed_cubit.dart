import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';

part 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedState.initial()) {
    loadFeed();
  }

  final clientRepo = Dependencies().clientRepository;

  void loadFeed() async {
    emit(FeedState.loading());

    final result = await clientRepo.getMastersFeed();

    safeEmit(result.when(ok: (data) => FeedState.loaded(data), err: (e, st) => FeedState.error(parseError(e, st))));
  }
}
