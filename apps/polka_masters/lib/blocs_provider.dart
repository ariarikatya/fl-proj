import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

class MasterBlocsProvider extends BlocsProvider {
  MasterBlocsProvider()
    : super(
        factories: {
          CitySearchCubit: (_) => CitySearchCubit(Dependencies().dio),
          AddressSearchCubit: (_) => AddressSearchCubit(Dependencies().dio),
          ChatsCubit: (ctx) => ChatsCubit(
            websockets: Dependencies().webSocketService,
            chatsRepo: Dependencies().chatsRepo,
            profileRepository: Dependencies().profileRepository,
            userId: MasterScope.of(ctx, listen: false).master.id,
          ),
        },
      );
}
