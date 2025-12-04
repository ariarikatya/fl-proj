import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/widgets/thanks_for_review_bottom_sheet.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/appointment_confirmation_page.dart';
import 'package:polka_clients/features/master_appointment/widgets/slots_page.dart';
import 'package:polka_clients/features/reviews/review_page.dart';
import 'package:shared/shared.dart';

part 'bookings_state.dart';

@Deprecated('Use one of the BookingCubit variants')
class OldBookingsCubit extends Cubit<BookingsState> {
  OldBookingsCubit() : super(const BookingsState()) {
    load();
  }

  final bookingsRepo = Dependencies().bookingsRepo;

  int? _newBookingId;
  bool _isLoading = false;

  /// sets new booking id which will be used for showing animation
  int? get newBookingId => _newBookingId;

  /// Sets new booking id and loads bookings
  void setNewBookingId(int id) {
    logger.debug('setting new booking id: $id');
    _newBookingId = id;
    load();
  }

  /// Sets new booking id to null and cancels further animations
  void markAsRead() {
    logger.debug('marking booking as read');
    _newBookingId = null;
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;

    bookingsRepo.getPendingBookings().then(
      (result) => result.when(
        ok: (data) => safeEmit(state.copyWith(pending: () => {for (var e in data) e.id: e})),
        err: (e, st) => handleError(e, st),
      ),
    );
    bookingsRepo.getUpcomingBookings().then(
      (result) => result.when(
        ok: (data) => safeEmit(state.copyWith(upcoming: () => {for (var e in data) e.id: e})),
        err: (e, st) => handleError(e, st),
      ),
    );
    bookingsRepo.getCompletedBookings().then(
      (result) => result.when(
        ok: (data) => safeEmit(state.copyWith(completed: () => {for (var e in data) e.id: e})),
        err: (e, st) => handleError(e, st),
      ),
    );

    _isLoading = false;
  }

  Future<AvailableSlot?> getAvailableSlot(BuildContext context, int serviceId, int masterId) async {
    final slot = await context.ext.push<AvailableSlot>(SlotsPage(serviceId: serviceId, masterId: masterId));
    if (slot != null) {
      Dependencies().analytics.reportEvent(
        'user_picked_slot',
        params: {
          'service_id': serviceId,
          'master_id': masterId,
          'slot_id': slot.id,
          'slot_datetime_utc': slot.datetime.toUtc().toIso8601String(),
        },
      );
    }
    return slot;
  }

  Future<bool> cancelAppointment(BuildContext context, int bookingId) async {
    final result = await bookingsRepo.cancelAppointment(bookingId);
    result.maybeWhen(ok: (data) => setNewBookingId(bookingId), err: (e, st) => handleError(e, st));
    return result.isOk;
  }

  Future<bool> changeAppointmentTime(BuildContext context, Booking booking) async {
    final slot = await getAvailableSlot(context, booking.serviceId, booking.masterId);
    if (slot == null || !context.mounted) return false;

    final result = await bookingsRepo.changeAppointmentTime(booking.id, slot.id, '');
    result.maybeWhen(ok: (data) => setNewBookingId(booking.id), err: (e, st) => handleError(e, st));
    return result.isOk;
  }

  Future<void> startAppointmentFlow(BuildContext context, Master master, Service service) async {
    Dependencies().analytics.reportEvent(
      'user_started_booking',
      params: {'service_id': service.id, 'master_id': master.id},
    );
    final slot = await getAvailableSlot(context, service.id, master.id);
    if (slot != null && context.mounted) {
      final confirm = await context.ext.push<bool>(
        AppointmentConfirmationPage(slot: slot, master: master, service: service),
      );
      if (confirm == true && context.mounted) {
        makeAppointment(context, service.id, slot.id);
      }
    }
  }

  Future<void> makeAppointment(BuildContext context, int serviceId, int slotId) async {
    final clientRepo = Dependencies().clientRepository;
    final result = await clientRepo.makeAppointment(serviceId: serviceId, slotId: slotId, notes: null);
    result.when(
      ok: (id) {
        context.read<OldBookingsCubit>().setNewBookingId(id);
        context.read<HomeNavigationCubit>().openBookings();
        Dependencies().analytics.reportEvent(
          'user_booked_service',
          params: {'service_id': serviceId, 'slot_id': slotId},
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      err: (e, st) => handleError(e, st),
    );
  }

  Future<void> startReviewFlow(BuildContext context, Booking booking) async {
    final review = await context.ext.push<bool>(ReviewPage(booking: booking));
    if (review == true && context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      showModalBottomSheet(context: context, builder: (_) => const ThanksForReviewBottomSheet());
    }
  }
}
