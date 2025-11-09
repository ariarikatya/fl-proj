import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/controllers/events_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_groups_cubit.dart';
import 'package:polka_masters/features/contacts/controller/contact_search_cubit.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class MasterBlocsProvider extends BlocsProvider {
  MasterBlocsProvider()
    : super(
        factories: {
          CitySearchCubit: (_) => CitySearchCubit(Dependencies().dio),
          AddressSearchCubit: (_) => AddressSearchCubit(Dependencies().dio),
          ContactSearchCubit: (_) => ContactSearchCubit(Dependencies().contactsRepo),
          ChatsCubit: (ctx) => ChatsCubit(
            websockets: Dependencies().webSocketService,
            chatsRepo: Dependencies().chatsRepo,
            profileRepository: Dependencies().profileRepository,
            userId: ctx.read<MasterScope>().master.id,
          ),
          EventsCubit: (ctx) => EventsCubit(ctx, Dependencies().bookingsRepository, Dependencies().webSocketService),
          ContactGroupsCubit: (ctx) => ContactGroupsCubit(Dependencies().contactsRepo),
          PendingBookingsCubit: (ctx) =>
              PendingBookingsCubit(Dependencies().bookingsRepository, Dependencies().webSocketService),
        },
      );
}
