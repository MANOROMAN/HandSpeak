import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime dateOfBirth;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.dateOfBirth,
    this.isEmailVerified = false,
    this.preferences,
  });

  // Helper property to get full name
  String get name => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        photoUrl,
        createdAt,
        dateOfBirth,
        isEmailVerified,
        preferences,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences ?? {},
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      dateOfBirth: map['dateOfBirth'] is Timestamp
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : DateTime.now(),
      isEmailVerified: map['isEmailVerified'] ?? false,
      preferences: map['preferences'],
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
    );
  }
}