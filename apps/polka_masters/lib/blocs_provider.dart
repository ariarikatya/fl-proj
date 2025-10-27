import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/controllers/events_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:shared/shared.dart';

class MasterBlocsProvider extends BlocsProvider {
  MasterBlocsProvider()
    : super(
        factories: {
          CitySearchCubit: (_) => CitySearchCubit(Dependencies().dio),
          AddressSearchCubit: (_) => AddressSearchCubit(Dependencies().dio),
          ContactSearchCubit: (_) => ContactSearchCubit(Dependencies().dio, Dependencies().contactsRepo),
          ChatsCubit: (ctx) => ChatsCubit(
            websockets: Dependencies().webSocketService,
            chatsRepo: Dependencies().chatsRepo,
            profileRepository: Dependencies().profileRepository,
            userId: MasterScope.of(ctx, listen: false).master.id,
          ),
          EventsCubit: (ctx) => EventsCubit(ctx, Dependencies().bookingsRepository, Dependencies().webSocketService),
        },
      );
}
