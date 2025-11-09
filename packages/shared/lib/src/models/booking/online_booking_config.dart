import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum OnlineBookingPublicMode {
  public,
  private,
  off;

  static OnlineBookingPublicMode fromJson(String key) =>
      values.firstWhere((e) => e.name == key, orElse: () => OnlineBookingPublicMode.off);

  Object? toJson() => name;
}

class OnlineBookingConfig extends Equatable {
  const OnlineBookingConfig({required this.masterLink, required this.publicMode, required this.nightMode});

  factory OnlineBookingConfig.fromJson(Map<String, dynamic> json) => OnlineBookingConfig(
    masterLink: json['master_link'] as String,
    publicMode: OnlineBookingPublicMode.fromJson(json['public_mode'] as String),
    nightMode: json['night_mode'] as bool,
  );

  final String masterLink;
  final OnlineBookingPublicMode publicMode;
  final bool nightMode;

  @override
  List<Object?> get props => [masterLink, publicMode, nightMode];

  OnlineBookingConfig copyWith({
    ValueGetter<String>? masterLink,
    ValueGetter<OnlineBookingPublicMode>? publicMode,
    ValueGetter<bool>? nightMode,
  }) => OnlineBookingConfig(
    masterLink: masterLink != null ? masterLink() : this.masterLink,
    publicMode: publicMode != null ? publicMode() : this.publicMode,
    nightMode: nightMode != null ? nightMode() : this.nightMode,
  );

  Map<String, dynamic> toJson() => {
    'master_link': masterLink,
    'public_mode': publicMode.toJson(),
    'night_mode': nightMode,
  };
}
