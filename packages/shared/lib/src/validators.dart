import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

abstract class Validators {
  static FormFieldValidator<String> get isNotEmpty => (value) {
    if (value == null || value.isEmpty) {
      return 'Это поле не может быть пустым';
    }
    return null;
  };

  static FormFieldValidator<String> get email => (value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!EmailValidator.validate(value)) {
      return 'Пожалуйста, введите корректный email';
    }
    return null;
  };

  static FormFieldValidator<String> get fullName => (value0) {
    final value = value0?.trim();
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите имя и фамилию';
    }
    final parts = value.split(' ');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) {
      return 'Пожалуйста, введите имя и фамилию через пробел';
    }
    return null;
  };
}
