import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

sealed class BookingsRepository {
  Future<Result<BookingInfo>> getBookingInfo(int bookingId);
  Future<Result<List<Booking>>> getAllBookings();
  Future<Result> confirmBooking(int bookingId);
  Future<Result> completeBooking(int bookingId);

  /// Reject pending booking
  Future<Result> rejectBooking(int bookingId);

  /// Cancel confirmed booking
  Future<Result> cancelBooking(int bookingId);

  Future<Result<Booking>> createBooking({
    required int clientId,
    required int serviceId,
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? notes,
  });

  Future<Result<bool>> blockTime({
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  });

  Future<Result<Booking?>> updateBooking({
    required int bookingId,
    int? serviceId,
    Duration? startTime,
    Duration? endTime,
    DateTime? date,
  });

  Future<Result<bool>> unblockTime({required DateTime date, required Duration startTime, required Duration endTime});
}

final class RestBookingsRepository extends BookingsRepository {
  RestBookingsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<List<Booking>>> getAllBookings() => tryCatch(() async {
    final response = await dio.get('/appointments');
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result> confirmBooking(int bookingId) => tryCatch(() async {
    await dio.patch('/appointments/$bookingId/confirm');
    return Result.ok(null);
  });

  @override
  Future<Result> rejectBooking(int bookingId) => tryCatch(() async {
    await dio.patch('/appointments/$bookingId/reject');
    return Result.ok(null);
  });

  @override
  Future<Result> cancelBooking(int bookingId) => tryCatch(() async {
    await dio.patch('/appointments/$bookingId/cancel');
    return Result.ok(null);
  });

  @override
  Future<Result> completeBooking(int bookingId) => tryCatch(() async {
    await dio.patch('/appointments/$bookingId/complete', data: {'finished': true});
    return Result.ok(null);
  });

  @override
  Future<Result<Booking>> createBooking({
    required int clientId,
    required int serviceId,
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? notes,
  }) => tryCatch(() async {
    final response = await dio.post(
      '/appointments/create-by-master',
      data: {
        'client_id': clientId,
        'service_id': serviceId,
        'date': date.toJson(),
        'start_time': startTime.toJson(),
        'end_time': endTime.toJson(),
        'notes': ?notes,
      },
    );
    return Booking.fromJson(response.data);
  });

  @override
  Future<Result<bool>> blockTime({
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  }) => tryCatch(() async {
    final response = await dio.post(
      '/master/block-time',
      data: {"date": date.toJson(), "start_time": startTime.toJson(), "end_time": endTime.toJson(), "reason": ?reason},
    );
    return response.data['success'] as bool;
  });

  @override
  Future<Result<bool>> unblockTime({required DateTime date, required Duration startTime, required Duration endTime}) =>
      tryCatch(() async {
        final response = await dio.post(
          '/master/unblock-time',
          data: {"date": date.toJson(), "start_time": startTime.toJson(), "end_time": endTime.toJson()},
        );
        return response.data['success'] as bool;
      });

  @override
  Future<Result<BookingInfo>> getBookingInfo(int bookingId) => tryCatch(() async {
    final response = await dio.get('/appointment-info?appointment_id=$bookingId');
    return BookingInfo.fromJson(response.data);
  });

  @override
  Future<Result<Booking?>> updateBooking({
    required int bookingId,
    int? serviceId,
    Duration? startTime,
    Duration? endTime,
    DateTime? date,
  }) => tryCatch(() async {
    final body = {
      'service_id': ?serviceId,
      'start_time': ?startTime?.toJson(),
      'end_time': ?endTime?.toJson(),
      'date': ?date?.toJson(),
    };
    final response = await dio.put('/master/appointment/$bookingId', data: body);
    return null;
    return Booking.fromJson(response.data); // Потому что поля на бэке своей жизнью живут
  });
}
