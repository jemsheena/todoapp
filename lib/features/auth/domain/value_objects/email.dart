import 'package:freezed_annotation/freezed_annotation.dart';

part 'email.freezed.dart';

@freezed
class Email with _$Email {
  const Email._();

  const factory Email(String value) = _Email;

  bool get isValid {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(value);
  }

  String? get validationError {
    if (value.isEmpty) {
      return 'Email is required';
    }
    if (!isValid) {
      return 'Invalid email format';
    }
    return null;
  }
}


