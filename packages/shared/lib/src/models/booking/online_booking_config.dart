import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum OnlineBookingVisibility {
  public,
  closed,
  off;

  static OnlineBookingVisibility fromJson(String key) =>
      values.firstWhere((e) => e.name == key, orElse: () => OnlineBookingVisibility.off);

  Object? toJson() => name;
}

class OnlineBookingConfig extends Equatable {
  const OnlineBookingConfig({required this.publicLink, required this.visibility, required this.nightStop});

  factory OnlineBookingConfig.fromJson(Map<String, dynamic> json) => OnlineBookingConfig(
    publicLink: json['public_link'] as String,
    visibility: OnlineBookingVisibility.fromJson(json['visibility'] as String),
    nightStop: json['night_stop'] as bool,
  );

  final String publicLink;
  final OnlineBookingVisibility visibility;
  final bool nightStop;

  @override
  List<Object?> get props => [publicLink, visibility, nightStop];

  OnlineBookingConfig copyWith({
    ValueGetter<String>? publicLink,
    ValueGetter<OnlineBookingVisibility>? visibility,
    ValueGetter<bool>? nightStop,
  }) => OnlineBookingConfig(
    publicLink: publicLink != null ? publicLink() : this.publicLink,
    visibility: visibility != null ? visibility() : this.visibility,
    nightStop: nightStop != null ? nightStop() : this.nightStop,
  );

  Map<String, dynamic> toJson() => {
    'master_link': publicLink,
    'public_mode': visibility.toJson(),
    'night_mode': nightStop,
  };
}
