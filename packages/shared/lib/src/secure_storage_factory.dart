import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage createSecureStorage() =>
    FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
