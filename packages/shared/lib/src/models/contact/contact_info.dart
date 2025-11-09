import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/src/models/booking/booking.dart';
import 'package:shared/src/models/contact/contact.dart';
import 'package:shared/src/utils.dart';

class ContactInfo extends Equatable {
  const ContactInfo({required this.contact, required this.lastBookings, required this.totalAppointmentsCount});

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    contact: Contact.fromJson(json),
    lastBookings: parseJsonList((json['last_appointments'] as List).cast<Map<String, dynamic>>(), Booking.fromJson),
    totalAppointmentsCount: json['total_appointments_count'] as int,
  );

  final Contact contact;
  final List<Booking> lastBookings;
  final int totalAppointmentsCount;

  @override
  List<Object?> get props => [contact, lastBookings, totalAppointmentsCount];

  ContactInfo copyWith({
    ValueGetter<Contact>? contact,
    ValueGetter<List<Booking>>? lastBookings,
    ValueGetter<int>? totalAppointmentsCount,
  }) => ContactInfo(
    contact: contact != null ? contact() : this.contact,
    lastBookings: lastBookings != null ? lastBookings() : this.lastBookings,
    totalAppointmentsCount: totalAppointmentsCount != null ? totalAppointmentsCount() : this.totalAppointmentsCount,
  );

  Map<String, dynamic> toJson() => {
    ...contact.toJson(),
    'last_appointments': lastBookings.map((e) => e.toJson()).toList(),
    'total_appointments_count': totalAppointmentsCount,
  };
}
