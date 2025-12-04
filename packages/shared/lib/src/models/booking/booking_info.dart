import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/booking/booking.dart';
import 'package:shared/src/models/client.dart';
import 'package:shared/src/models/contact/contact.dart';
import 'package:shared/src/models/service/service.dart';

class BookingInfo extends JsonEquatable {
  const BookingInfo({
    required this.booking,
    required this.client,
    required this.contact,
    required this.service,
    super.json,
  });

  factory BookingInfo.fromJson(Map<String, dynamic> json) => BookingInfo(
    booking: Booking.fromJson(json['appointment']),
    client: json['client'] != null ? Client.fromJson(json['client']) : null,
    contact: json['contact'] != null
        ? Contact.fromJson(json['contact'])
        : throw StateError('contact is required field in booking info'),
    service: Service.fromJson(json['service']),
    json: json,
  );

  final Booking booking;
  final Client? client;
  final Contact contact;
  final Service service;

  @override
  List<Object?> get props => [booking, client, contact, service];

  BookingInfo copyWith({
    ValueGetter<Booking>? booking,
    ValueGetter<Client>? client,
    ValueGetter<Contact>? contact,
    ValueGetter<Service>? service,
  }) => BookingInfo(
    booking: booking != null ? booking() : this.booking,
    client: client != null ? client() : this.client,
    contact: contact != null ? contact() : this.contact,
    service: service != null ? service() : this.service,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'appointment': booking.toJson(),
    'client': ?client?.toJson(),
    'contact': contact.toJson(),
    'service': service.toJson(),
  };
}
