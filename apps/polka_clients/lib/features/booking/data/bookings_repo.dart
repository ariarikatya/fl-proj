import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

typedef BookingData = ({Booking booking, Service service, Master master});

sealed class BookingsRepository {
  Future<Result<List<Booking>>> getPendingBookings({int limit = 10, int offset = 0});
  Future<Result<List<Booking>>> getUpcomingBookings({int limit = 10, int offset = 0});
  Future<Result<List<Booking>>> getCompletedBookings({int limit = 10, int offset = 0});
  Future<Result<BookingData>> getBookingInfo(int bookingId);

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
  Future<Result<List<Booking>>> getCompletedBookings({int limit = 10, int offset = 0}) => tryCatch(() async {
    final response = await dio.get('/user/appointments/completed', queryParameters: {'limit': limit, 'offset': offset});
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result<List<Booking>>> getPendingBookings({int limit = 10, int offset = 0}) => tryCatch(() async {
    final response = await dio.get('/user/appointments/pending', queryParameters: {'limit': limit, 'offset': offset});
    return parseJsonList(response.data['appointments'], Booking.fromJson);
  });

  @override
  Future<Result<List<Booking>>> getUpcomingBookings({int limit = 10, int offset = 0}) => tryCatch(() async {
    final response = await dio.get('/user/appointments/upcoming', queryParameters: {'limit': limit, 'offset': offset});
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
  Future<Result<BookingData>> getBookingInfo(int bookingId) => tryCatch(() async {
    final response = await dio.get('/appointments/$bookingId');
    final master = Master.fromJson(response.data['master']);
    final booking = Booking.fromJson(response.data['appointment']);
    final service = Service.fromJson(response.data['service']);
    return (booking: booking, service: service, master: master);
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
