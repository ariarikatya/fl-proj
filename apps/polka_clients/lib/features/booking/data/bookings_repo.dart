import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class BookingsRepository {
  Future<Result<List<Booking>>> getPendingBookings();
  Future<Result<List<Booking>>> getUpcomingBookings();
  Future<Result<List<Booking>>> getCompletedBookings();

  Future<Result<int>> changeAppointmentTime(int bookingId, int newSlotId, String reason);
  Future<Result<int>> cancelAppointment(int bookingId);

  Future<Result<bool>> leaveReview(
    int bookingId,
    int rating,
    List<ReviewTags> tags,
    String comment,
    List<String> images,
  );
}

final class RestBookingsRepository extends BookingsRepository {
  RestBookingsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<List<Booking>>> getCompletedBookings() => tryCatch(() async {
    final response = await dio.get('/user/appointments/completed');
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result<List<Booking>>> getPendingBookings() => tryCatch(() async {
    final response = await dio.get('/user/appointments/pending');
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result<List<Booking>>> getUpcomingBookings() => tryCatch(() async {
    final response = await dio.get('/user/appointments/upcoming');
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result<int>> changeAppointmentTime(int bookingId, int newSlotId, String reason) => tryCatch(() async {
    final response = await dio.patch(
      '/appointments/$bookingId/reschedule',
      data: {'new_slot_id': newSlotId, 'reason': reason},
    );
    return response.data['id'] as int;
  });

  @override
  Future<Result<int>> cancelAppointment(int bookingId) => tryCatch(() async {
    final response = await dio.patch('/appointments/$bookingId/cancel');
    return response.data['id'] as int;
  });

  @override
  Future<Result<bool>> leaveReview(
    int bookingId,
    int rating,
    List<ReviewTags> tags,
    String comment,
    List<String> images,
  ) => tryCatch(() async {
    await dio.post(
      '/reviews/appointment',
      data: {
        'appointment_id': bookingId,
        'rating': rating,
        'tags': tags.map((e) => e.toJson()).toList(),
        'comment': comment,
        'photos': images,
      },
    );
    return true;
  });
}
