import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';

class Contact extends JsonEquatable {
  const Contact({required this.id, required this.name, required this.number, required this.avatarUrl, super.json});

  factory Contact.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json case <String, Object?>{'first_name': String firstName, 'last_name': String lastName}) {
      name = '$firstName $lastName';
    }
    return Contact(
      id: json['id'] as int,
      name: name ?? (json['name'] ?? json['display_name']) as String,
      number: (json['phone'] ?? json['phone_number']) as String,
      avatarUrl: json['avatar_url'] as String?,
      json: json,
    );
  }

  final int id;
  final String name, number;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, number, avatarUrl];

  Contact copyWith({
    ValueGetter<int>? id,
    ValueGetter<String>? name,
    ValueGetter<String>? number,
    ValueGetter<String?>? avatarUrl,
  }) => Contact(
    id: id != null ? id() : this.id,
    name: name != null ? name() : this.name,
    number: number != null ? number() : this.number,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'number': number, 'avatar_url': avatarUrl};
}
