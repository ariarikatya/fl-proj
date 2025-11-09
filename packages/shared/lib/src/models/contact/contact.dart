import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/extensions/datetime.dart';
import 'package:shared/src/models/contact/contact_group.dart';
import 'package:shared/src/widgets/masks/phone_mask.dart';

class Contact extends JsonEquatable {
  const Contact({
    required this.id,
    required this.name,
    required this.number,
    this.avatarUrl,
    this.city,
    this.email,
    this.notes,
    this.lastAppointmentDate,
    this.birthday,
    this.group,
    this.clientId,
    this.isBlocked = false,
    super.json,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json case <String, Object?>{'first_name': String firstName, 'last_name': String lastName}) {
      name = '$firstName $lastName';
    }
    final avatarUrl = json['avatar_url'] as String?;

    return Contact(
      id: json['id'] as int,
      name: name ?? (json['name'] ?? json['display_name']) as String,
      number: (json['phone'] ?? json['phone_number']) as String,
      avatarUrl: avatarUrl?.isNotEmpty == true ? avatarUrl : null,
      city: json['city'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      lastAppointmentDate: DateTime.tryParse(json['last_appointment_date'] as String? ?? ""),
      birthday: DateTime.tryParse(json['birthday'] as String? ?? ""),
      group: ContactGroup.fromJson(json['category'] as String? ?? ""),
      clientId: json['client_id'] as int?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      json: json,
    );
  }

  final int id;
  final int? clientId;
  final String name, number;
  final String? avatarUrl, city, email, notes;
  final ContactGroup? group;
  final DateTime? lastAppointmentDate, birthday;
  final bool isBlocked;

  String get numberDigitsOnly => number.replaceAll(RegExp(r'[^0-9]'), '');

  String get numberFormatted => phoneMask.maskText(number.replaceAll('+', '').substring(1));

  String get initials {
    final parts = name.split(' ');
    return parts.where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    number,
    avatarUrl,
    city,
    email,
    notes,
    lastAppointmentDate,
    birthday,
    group,
    clientId,
    isBlocked,
  ];

  Contact copyWith({
    ValueGetter<int>? id,
    ValueGetter<String>? name,
    ValueGetter<String>? number,
    ValueGetter<String?>? avatarUrl,
    ValueGetter<String?>? city,
    ValueGetter<String?>? email,
    ValueGetter<String?>? notes,
    ValueGetter<DateTime?>? lastAppointmentDate,
    ValueGetter<DateTime?>? birthday,
    ValueGetter<ContactGroup?>? group,
    ValueGetter<int?>? clientId,
    ValueGetter<bool>? isBlocked,
  }) => Contact(
    id: id != null ? id() : this.id,
    name: name != null ? name() : this.name,
    number: number != null ? number() : this.number,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    city: city != null ? city() : this.city,
    email: email != null ? email() : this.email,
    notes: notes != null ? notes() : this.notes,
    lastAppointmentDate: lastAppointmentDate != null ? lastAppointmentDate() : this.lastAppointmentDate,
    birthday: birthday != null ? birthday() : this.birthday,
    group: group != null ? group() : this.group,
    clientId: clientId != null ? clientId() : this.clientId,
    isBlocked: isBlocked != null ? isBlocked() : this.isBlocked,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': number,
    'avatar_url': ?avatarUrl,
    'city': ?city,
    'email': ?email,
    'notes': ?notes,
    'last_appointment_date': ?lastAppointmentDate?.toJson(),
    'birthday': ?birthday?.toJson(),
    'category': ?group?.toJson(),
    'client_id': ?clientId,
    'is_blocked': isBlocked,
  };
}
