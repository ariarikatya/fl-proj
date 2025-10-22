import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class MasterRepository {
  Future<Result<Service>> createMasterService(Service service);
  Future<Result<Schedule>> createMasterSchedule(Schedule schedule);

  Future<Result<List<Booking>>> getAllBookings();
  Future<Result> confirmBooking(int bookingId);
  Future<Result> rejectBooking(int bookingId);
  Future<Result> cancelBooking(int bookingId);
  Future<Result> completeBooking(int bookingId);

  /// Takes a list of filepaths for photos
  Future<Result<List<String>>> uploadPortfolioPhotos(Iterable<String> photos);
}

class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Service>> createMasterService(Service service) async {
    try {
      await dio.post('/master_service', data: service.toJson());
      return Result.ok(service);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<Schedule>> createMasterSchedule(Schedule schedule) async {
    try {
      await dio.post(
        '/schedules',
        data: schedule.toJson()
          ..['slot_interval_min'] = 30
          ..['auto_generate_slots'] = true,
      );
      return Result.ok(schedule);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<List<String>>> uploadPortfolioPhotos(Iterable<String> photos) async {
    try {
      final formData = FormData.fromMap({'photos': photos.map((f) => MultipartFile.fromFileSync(f)).toList()});
      final result = await dio.post('/master/photos/portfolio', data: formData);
      return Result.ok((result.data['general_portfolio'] as List).cast<String>());
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

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
}
