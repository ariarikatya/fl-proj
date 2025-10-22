import 'package:equatable/equatable.dart';

abstract class JsonEquatable extends Equatable {
  const JsonEquatable({this.json});
  final Map<String, Object?>? json; // For showing initial json from API in debug

  String get debugName => runtimeType.toString();

  Map<String, Object?> toJson();
}
