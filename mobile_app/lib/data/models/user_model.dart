import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String contactNumber;
  final String address;
  final String gender;
  final DateTime? birthdate;
  final String? idImageUrl;
  final bool isVerified;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.address,
    required this.gender,
    this.birthdate,
    this.idImageUrl,
    this.isVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> m, String uid) => UserModel(
        uid: uid,
        fullName: m['fullName'] ?? '',
        email: m['email'] ?? '',
        contactNumber: m['contactNumber'] ?? '',
        address: m['address'] ?? '',
        gender: m['gender'] ?? '',
        birthdate: (m['birthdate'] as Timestamp?)?.toDate(),
        idImageUrl: m['idImageUrl'],
        isVerified: m['isVerified'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'contactNumber': contactNumber,
        'address': address,
        'gender': gender,
        'birthdate': birthdate != null ? Timestamp.fromDate(birthdate!) : null,
        'idImageUrl': idImageUrl,
        'isVerified': isVerified,
      };

  UserModel copyWith({
    String? fullName,
    String? email,
    String? contactNumber,
    String? address,
    String? gender,
    DateTime? birthdate,
    String? idImageUrl,
    bool? isVerified,
  }) =>
      UserModel(
        uid: uid,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        contactNumber: contactNumber ?? this.contactNumber,
        address: address ?? this.address,
        gender: gender ?? this.gender,
        birthdate: birthdate ?? this.birthdate,
        idImageUrl: idImageUrl ?? this.idImageUrl,
        isVerified: isVerified ?? this.isVerified,
      );
}
