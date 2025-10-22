import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/src/extensions/datetime.dart';

enum ReviewTags {
  neatness('🧼', 'Аккуратность'),
  care('‍🤲', 'Забота'),
  punctuality('‍‍⏱️', 'Пунктуальность'),
  communication('💬', 'Общение'),
  qualityMaterials('‍🧴', 'Качественные материалы'),
  atmosphere('‍🕯️', 'Атмосфера');

  const ReviewTags(this.emoji, this.text);

  String get label => '$emoji $text';

  static ReviewTags fromJson(String value) =>
      ReviewTags.values.firstWhere((e) => e.name == value, orElse: () => ReviewTags.neatness);

  Object? toJson() => name;

  final String emoji;
  final String text;
}

class Review extends Equatable {
  const Review({
    required this.id,
    required this.bookingId,
    required this.clientId,
    required this.masterId,
    required this.rating,
    required this.comment,
    required this.status,
    required this.masterReply,
    required this.clientName,
    required this.clientAvatarUrl,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.photos,
    required this.createdAt,
    required this.repliedAt,
    required this.tags,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as int,
    bookingId: json['booking_id'] as int,
    clientId: json['client_id'] as int,
    masterId: json['master_id'] as int,
    rating: json['rating'] as int,
    comment: json['comment'] as String,
    status: json['status'] as String,
    masterReply: json['master_reply'] as String,
    clientName: json['client_name'] as String? ?? '',
    clientAvatarUrl: json['client_avatar_url'] as String? ?? '',
    serviceTitle: json['service_title'] as String? ?? '',
    serviceCategory: json['service_category'] as String? ?? '',
    photos: (json['photos'] as List).cast<String>(),
    createdAt: DateTime.parse(json['created_at'] as String),
    repliedAt: DateTime.tryParse(json['replied_at'] as String? ?? ''),
    tags: (json['tags'] as List).cast<String>().map((e) => ReviewTags.fromJson(e)).toList(),
  );

  final int id, bookingId, clientId, masterId, rating;
  final String comment, status, masterReply, clientName, clientAvatarUrl, serviceTitle, serviceCategory;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime? repliedAt;
  final List<ReviewTags> tags;

  @override
  List<Object?> get props => [
    id,
    bookingId,
    clientId,
    masterId,
    rating,
    comment,
    status,
    masterReply,
    clientName,
    clientAvatarUrl,
    serviceTitle,
    serviceCategory,
    photos,
    createdAt,
    repliedAt,
    tags,
  ];

  Review copyWith({
    ValueGetter<int>? id,
    ValueGetter<int>? bookingId,
    ValueGetter<int>? clientId,
    ValueGetter<int>? masterId,
    ValueGetter<int>? rating,
    ValueGetter<String>? comment,
    ValueGetter<String>? status,
    ValueGetter<String>? masterReply,
    ValueGetter<String>? clientName,
    ValueGetter<String>? clientAvatarUrl,
    ValueGetter<String>? serviceTitle,
    ValueGetter<String>? serviceCategory,
    ValueGetter<List<String>>? photos,
    ValueGetter<DateTime>? createdAt,
    ValueGetter<DateTime?>? repliedAt,
    ValueGetter<List<ReviewTags>>? tags,
  }) => Review(
    id: id != null ? id() : this.id,
    bookingId: bookingId != null ? bookingId() : this.bookingId,
    clientId: clientId != null ? clientId() : this.clientId,
    masterId: masterId != null ? masterId() : this.masterId,
    rating: rating != null ? rating() : this.rating,
    comment: comment != null ? comment() : this.comment,
    status: status != null ? status() : this.status,
    masterReply: masterReply != null ? masterReply() : this.masterReply,
    clientName: clientName != null ? clientName() : this.clientName,
    clientAvatarUrl: clientAvatarUrl != null ? clientAvatarUrl() : this.clientAvatarUrl,
    serviceTitle: serviceTitle != null ? serviceTitle() : this.serviceTitle,
    serviceCategory: serviceCategory != null ? serviceCategory() : this.serviceCategory,
    photos: photos != null ? photos() : this.photos,
    createdAt: createdAt != null ? createdAt() : this.createdAt,
    repliedAt: repliedAt != null ? repliedAt() : this.repliedAt,
    tags: tags != null ? tags() : this.tags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookingId': bookingId,
    'clientId': clientId,
    'masterId': masterId,
    'rating': rating,
    'comment': comment,
    'status': status,
    'masterReply': masterReply,
    'clientName': clientName,
    'clientAvatarUrl': clientAvatarUrl,
    'serviceTitle': serviceTitle,
    'serviceCategory': serviceCategory,
    'photos': photos,
    'createdAt': createdAt.toJson(),
    'repliedAt': repliedAt?.toJson(),
    'tags': tags.map((e) => e.toJson()).toList(),
  };
}
