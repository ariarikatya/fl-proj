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

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit() : super(const BookingsState()) {
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

  void markAsReviewed(int bookingId) {
    logger.debug('marking booking as reviewed: $bookingId');
    final completed =
        state.completed?.map(
          (k, v) => MapEntry(k, v.copyWith(reviewSent: () => k == bookingId ? true : v.reviewSent)),
        ) ??
        {};
    safeEmit(state.copyWith(completed: () => completed));
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
    return await context.ext.push<AvailableSlot>(SlotsPage(serviceId: serviceId, masterId: masterId));
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
        blocs.get<BookingsCubit>(context).setNewBookingId(id);
        blocs.get<HomeNavigationCubit>(context).openBookings();
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
