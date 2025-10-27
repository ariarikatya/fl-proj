import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:shared/shared.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> addCalendarEvent(Booking booking) async {
  final Event event = Event(
    title: booking.serviceName,
    description: booking.masterNotes,
    location: '',
    startDate: booking.datetime,
    endDate: booking.datetime.add(booking.duration),
  );

  await Add2Calendar.addEvent2Cal(event);
}

Future<void> callMaster(int masterId) =>
    ChatsUtils().callNumber(Dependencies().clientRepository.getMasterPhone(masterId));

Future<void> showOnMap(BuildContext context, double latitude, double longitude, String title) async {
  Future<AvailableMap?> selectMap(List<AvailableMap> availableMaps) async {
    if (availableMaps.isEmpty || !context.mounted) return null;
    if (availableMaps.length == 1) return availableMaps.first;
    return showAvailableMapsDialog(context, availableMaps);
  }

  final availableMaps = await MapLauncher.installedMaps;
  logger.info('available maps: $availableMaps');

  final selectedMap = await selectMap(availableMaps);
  logger.info('selected map: $selectedMap');

  await selectedMap?.showMarker(coords: Coords(latitude, longitude), title: title);
}

Future<AvailableMap?> showAvailableMapsDialog(BuildContext context, List<AvailableMap> availableMaps) async {
  return await showListItemPickerBottomSheet<AvailableMap>(
    context: context,
    title: 'Выберите приложение для отображения карты',
    items: availableMaps,
    builder: (map) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText(map.mapName),
      horizontalTitleGap: 4,
      leading: SvgPicture.asset(map.icon, height: 30.0, width: 30.0),
    ),
  );
}

Future<void> leaveReview(BuildContext context, Booking booking) async {
  blocs.get<BookingsCubit>(context).startReviewFlow(context, booking);
}
