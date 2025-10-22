import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum BookingStatus {
  pending('Ждет подтверждения'),
  confirmed('Подтверждено'),
  completed('Завершено'),
  canceled('Отменено мастером'), // Canceled by master after confirmation
  rejected('Отклонено');

  const BookingStatus(this.label);
  final String label;

  Color get color => switch (this) {
    BookingStatus.confirmed => AppColors.success,
    BookingStatus.canceled => AppColors.error,
    BookingStatus.rejected => AppColors.error,
    _ => AppColors.textSecondary,
  };
}

class Booking extends JsonEquatable {
  const Booking({
    required this.id,
    required this.clientId,
    required this.masterId,
    required this.serviceId,
    required this.serviceName,
    required this.masterName,
    required this.price,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.startTime,
    required this.endTime,
    required this.serviceImageUrl,
    required this.masterAvatarUrl,
    required this.clientNotes,
    required this.masterNotes,
    required this.reviewSent,
    super.json,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as int,
    clientId: json['client_id'] as int,
    masterId: json['master_id'] as int,
    serviceId: json['service_id'] as int,
    serviceName: json['service_name'] as String,
    masterName: json['master_name'] as String? ?? '',
    price: json['price'] as int,
    status: BookingStatus.values.byName(json['status'] as String),
    date: DateTime.parse(json['date'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    startTime: DurationX.fromTimeString(json['start_time'] as String),
    endTime: DurationX.fromTimeString(json['end_time'] as String),
    serviceImageUrl: json['service_image_url'] as String?,
    masterAvatarUrl: json['master_avatar_url'] as String?,
    clientNotes: json['client_notes'] as String,
    masterNotes: json['master_notes'] as String,
    reviewSent: json['review_sent'] as bool? ?? false,
    json: json,
  );

  final int id, clientId, masterId, serviceId, price;
  final String serviceName, masterName, clientNotes, masterNotes;
  final BookingStatus status;
  final DateTime date, createdAt;
  final Duration startTime, endTime;
  final String? serviceImageUrl, masterAvatarUrl;
  final bool reviewSent;

  DateTime get datetime => date.add(startTime);
  Duration get duration => endTime - startTime;

  @override
  List<Object?> get props => [
    id,
    clientId,
    masterId,
    serviceId,
    price,
    serviceName,
    masterName,
    clientNotes,
    masterNotes,
    status,
    date,
    createdAt,
    startTime,
    endTime,
    serviceImageUrl,
    masterAvatarUrl,
    reviewSent,
  ];

  Booking copyWith({
    ValueGetter<String>? title,
    ValueGetter<int>? clientId,
    ValueGetter<int>? masterId,
    ValueGetter<int>? serviceId,
    ValueGetter<String>? serviceName,
    ValueGetter<String>? masterName,
    ValueGetter<int>? price,
    ValueGetter<BookingStatus>? status,
    ValueGetter<DateTime>? date,
    ValueGetter<DateTime>? createdAt,
    ValueGetter<Duration>? startTime,
    ValueGetter<Duration>? endTime,
    ValueGetter<String>? serviceImageUrl,
    ValueGetter<String>? masterAvatarUrl,
    ValueGetter<String>? clientNotes,
    ValueGetter<String>? masterNotes,
    ValueGetter<bool>? reviewSent,
  }) => Booking(
    id: id,
    clientId: clientId != null ? clientId() : this.clientId,
    masterId: masterId != null ? masterId() : this.masterId,
    serviceId: serviceId != null ? serviceId() : this.serviceId,
    serviceName: serviceName != null ? serviceName() : this.serviceName,
    masterName: masterName != null ? masterName() : this.masterName,
    price: price != null ? price() : this.price,
    status: status != null ? status() : this.status,
    date: date != null ? date() : this.date,
    createdAt: createdAt != null ? createdAt() : this.createdAt,
    startTime: startTime != null ? startTime() : this.startTime,
    endTime: endTime != null ? endTime() : this.endTime,
    serviceImageUrl: serviceImageUrl != null ? serviceImageUrl() : this.serviceImageUrl,
    masterAvatarUrl: masterAvatarUrl != null ? masterAvatarUrl() : this.masterAvatarUrl,
    clientNotes: clientNotes != null ? clientNotes() : this.clientNotes,
    masterNotes: masterNotes != null ? masterNotes() : this.masterNotes,
    reviewSent: reviewSent != null ? reviewSent() : this.reviewSent,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'master_id': masterId,
    'service_id': serviceId,
    'service_name': serviceName,
    'master_name': masterName,
    'price': price,
    'status': status.name,
    'date': date.toJson(),
    'start_time': startTime.toTimeString(),
    'end_time': endTime.toTimeString(),
    'service_image_url': serviceImageUrl,
    'master_avatar_url': masterAvatarUrl,
    'client_notes': clientNotes,
    'master_notes': masterNotes,
    'created_at': createdAt.toJson(),
    'review_sent': reviewSent,
  };
}
