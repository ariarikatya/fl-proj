import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/models/client.dart';
import 'package:shared/src/models/master/master.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

sealed class ProfileRepository {
  Future<Result<Client>> createClientProfile(String phone, Client client);
  Future<Result<Master>> createMasterProfile(String phone, Master master);

  Future<Result<bool>> updateAccountInfo(String? firstName, String? lastName, String? city, String? email);

  /// Returns Map where keys are local filepaths and values are corresponding uploaded urls
  Future<Result<Map<String, String>>> uploadPhotos(List<XFile> xfiles);

  /// Uploads single photo and returns image url
  Future<Result<String>> uploadSinglePhoto(XFile xfile);

  Future<Result<void>> uploadFcmToken(String token, String udid, String platform);
}

class RestProfileRepository extends ProfileRepository {
  RestProfileRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Client>> createClientProfile(String phone, Client client) async {
    try {
      final response = await dio.post(
        '/profile',
        data: {'phone': phone, 'profile': client.toJson()..["is_master"] = false},
      );
      return Result.ok(client.copyWith(id: () => response.data['client_profile']['id']));
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<Master>> createMasterProfile(String phone, Master master) async {
    try {
      final response = await dio.post(
        '/profile',
        data: {'phone': phone, 'profile': master.toJson()..["is_master"] = true},
      );
      return Result.ok(master.copyWith(id: () => response.data['master_profile']['id']));
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<bool>> updateAccountInfo(String? firstName, String? lastName, String? city, String? email) =>
      tryCatch(() async {
        await dio.put(
          '/user/data',
          data: {'first_name': ?firstName, 'last_name': ?lastName, 'city': ?city, 'email': email},
        );
        return true;
      });

  @override
  Future<Result<Map<String, String>>> uploadPhotos(List<XFile> xfiles) => tryCatch(() async {
    if (xfiles.isEmpty) {
      logger.debug('no photos to upload');
      return {};
    }

    logger.debug('uploading photos: ${xfiles.length} XFile(s)');
    var stopwatch = Stopwatch()..start();

    final data = FormData.fromMap({'images': xfiles.map((xfile) => MultipartFile.fromFileSync(xfile.path)).toList()});
    logger.debug('loaded photos in memory in ${stopwatch.elapsedMilliseconds}ms');
    stopwatch.reset();

    final response = await dio.post('/upload-image', data: data);
    logger.debug('uploaded photos to server in ${stopwatch.elapsedMilliseconds}ms');
    stopwatch.stop();

    return {
      for (var xfile in xfiles)
        // a little bit of abra-cadabra
        xfile.name: (response.data['images'] as List).firstWhere(
          (json) => json['file_name'] == xfile.name,
        )['image_url'],
    };
  });

  @override
  Future<Result<String>> uploadSinglePhoto(XFile xfile) => tryCatch(() async {
    final data = FormData.fromMap({
      'images': [MultipartFile.fromFileSync(xfile.path)],
    });
    final response = await dio.post('/upload-image', data: data);
    return (response.data['images'] as List).first['image_url'];
  });

  @override
  Future<Result<void>> uploadFcmToken(String token, String udid, String platform) => tryCatch(() async {
    final body = {'token': token, 'device_id': udid, 'platform': platform};
    await dio.post('/notifications/register-token', data: body);
    return;
  });
}
