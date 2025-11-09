import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

enum BookingStatus {
  pending('Ждет подтверждения'),
  confirmed('Подтверждено'),
  completed('Завершено'),
  canceled('Отменено'), // Canceled by master after confirmation
  rejected('Отклонено');

  const BookingStatus(this.label);
  final String label;

  Color colorOf(BuildContext context) => switch (this) {
    BookingStatus.confirmed => context.ext.theme.success,
    BookingStatus.canceled => context.ext.theme.error,
    BookingStatus.rejected => context.ext.theme.error,
    _ => context.ext.theme.textSecondary,
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
    required this.clientName,
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
    required this.isTimeBlock,
    super.json,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final clientNotes = json['client_notes'] as String? ?? '';
    final masterNotes = json['master_notes'] as String? ?? '';

    return Booking(
      id: (json['id'] ?? json['booking_id']) as int,
      clientId: json['client_id'] as int,
      masterId: json['master_id'] as int,
      serviceId: json['service_id'] as int,
      serviceName: json['service_name'] as String? ?? '',
      masterName: json['master_name'] as String? ?? '',
      clientName: json['client_name'] as String? ?? '',
      price: json['price'] as int,
      status: BookingStatus.values.byName(json['status'] as String),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      startTime: DurationX.fromTimeString(json['start_time'] as String),
      endTime: DurationX.fromTimeString(json['end_time'] as String),
      serviceImageUrl: json['service_image_url'] as String?,
      masterAvatarUrl: json['master_avatar_url'] as String?,
      clientNotes: clientNotes.isNotEmpty ? clientNotes : null,
      masterNotes: masterNotes.isNotEmpty ? masterNotes : null,
      reviewSent: json['review_sent'] as bool? ?? false,
      isTimeBlock: json['block_time'] as bool? ?? false,
      json: json,
    );
  }

  final int id, clientId, masterId, serviceId, price;
  final String serviceName, masterName, clientName;
  final BookingStatus status;
  final DateTime date, createdAt;
  final Duration startTime, endTime;
  final String? serviceImageUrl, masterAvatarUrl, clientNotes, masterNotes;
  final bool reviewSent, isTimeBlock;

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
    clientName,
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
    isTimeBlock,
  ];

  Booking copyWith({
    ValueGetter<String>? title,
    ValueGetter<int>? clientId,
    ValueGetter<int>? masterId,
    ValueGetter<int>? serviceId,
    ValueGetter<String>? serviceName,
    ValueGetter<String>? masterName,
    ValueGetter<String>? clientName,
    ValueGetter<int>? price,
    ValueGetter<BookingStatus>? status,
    ValueGetter<DateTime>? date,
    ValueGetter<DateTime>? createdAt,
    ValueGetter<Duration>? startTime,
    ValueGetter<Duration>? endTime,
    ValueGetter<String>? serviceImageUrl,
    ValueGetter<String>? masterAvatarUrl,
    ValueGetter<String?>? clientNotes,
    ValueGetter<String?>? masterNotes,
    ValueGetter<bool>? reviewSent,
    ValueGetter<bool>? isTimeBlock,
  }) => Booking(
    id: id,
    clientId: clientId != null ? clientId() : this.clientId,
    masterId: masterId != null ? masterId() : this.masterId,
    serviceId: serviceId != null ? serviceId() : this.serviceId,
    serviceName: serviceName != null ? serviceName() : this.serviceName,
    clientName: clientName != null ? clientName() : this.clientName,
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
    isTimeBlock: isTimeBlock != null ? isTimeBlock() : this.isTimeBlock,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'master_id': masterId,
    'service_id': serviceId,
    'service_name': serviceName,
    'master_name': masterName,
    'client_name': clientName,
    'price': price,
    'status': status.name,
    'date': date.toJson(),
    'start_time': startTime.toTimeString(),
    'end_time': endTime.toTimeString(),
    'service_image_url': serviceImageUrl,
    'master_avatar_url': masterAvatarUrl,
    'client_notes': ?clientNotes,
    'master_notes': ?masterNotes,
    'notes': ?masterNotes,
    'created_at': createdAt.toJson(),
    'review_sent': reviewSent,
    'block_time': isTimeBlock,
  };
}
