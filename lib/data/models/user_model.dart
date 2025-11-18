import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/partner_status.dart';
import '../enums/user_role.dart';

class UserModel extends Equatable {
  final UserRole role;
  final String id;
  final String email;
  final String? phone;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String country;
  final String postalCode;
  final String state;
  final String specificPersonaGoal;
  final bool isVerified;
  final DateTime? creationTimestamp;
  final String? photoUrl;
  final List<String> tags;
  final String? bio;
  final String? website;
  final PartnerStatus partnerStatus;
  final Map<String , double> location ;
  final String geohash;


  const UserModel({
    this.role = UserRole.partner,
    required this.id,
    required this.email,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.address = "",
    this.city = "",
    this.country = "",
    this.postalCode = "",
    this.state = "",
    this.specificPersonaGoal = "",
    this.isVerified = false,
    this.creationTimestamp,
    this.photoUrl,
    this.tags = const [],
    this.bio,
    this.website,
    this.partnerStatus = PartnerStatus.inactive,
    this.location = const {},
    this.geohash = "",
  });

  /// A computed property for the user's full name.
  String get name => '$firstName $lastName'.trim();

  factory UserModel.fromFirebaseUser(User firebaseUser) {
    final displayName = firebaseUser.displayName ?? "";
    final names = displayName.split(' ');
    
    return UserModel(
      role: UserRole.partner,
      id: firebaseUser.uid,
      email: firebaseUser.email ?? "",
      phone: firebaseUser.phoneNumber,
      firstName: names.isNotEmpty ? names.first : "",
      lastName: names.length > 1 ? names.sublist(1).join(' ') : "",
      address: "",
      city: "",
      country: "",
      postalCode: "",
      state: "",
      specificPersonaGoal: "",
      isVerified: firebaseUser.emailVerified,
      creationTimestamp: firebaseUser.metadata.creationTime ??DateTime.now(),
      photoUrl: firebaseUser.photoURL,
      tags: [],
      bio: "",
      website: "",
      partnerStatus: PartnerStatus.inactive,
      location: {},
      geohash: "",
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      role: UserRole.values
          .firstWhere((e) => e.name == map['role'], orElse: () => UserRole.partner),
      email: map['email'] as String,
      phone: map['phone'] as String?,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      country: map['country'] as String,
      postalCode: map['postalCode'] as String,
      state: map['state'] as String,
      specificPersonaGoal: map['specificPersonaGoal'] as String,
      isVerified: map['isVerified'] as bool,
      creationTimestamp: (map['creationTimestamp'] as Timestamp?)?.toDate(),
      photoUrl: map['photoUrl'] as String?,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      bio: map['bio'] as String?,
      website: map['website'] as String?,
      partnerStatus: PartnerStatus.values
          .firstWhere((e) => e.name == map['status'], orElse: () => PartnerStatus.inactive),
      location: map['location'] as Map<String, double>,
      geohash: map['geohash'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.name,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'state': state,
      'specificPersonaGoal': specificPersonaGoal,
      'isVerified': isVerified,
      'creationTimestamp': creationTimestamp != null
          ? Timestamp.fromDate(creationTimestamp!)
          : FieldValue.serverTimestamp(),
      'photoUrl': photoUrl,
      'tags': tags,
      'bio': bio,
      'website': website,
      'status': partnerStatus,
      'location': location,
      'geohash': geohash,
    };
  }

  UserModel copyWith({
  UserRole? role,
  String? id,
  String? email,
  String? phone,
  String? firstName,
  String? lastName,
  String? address,
  String? city,
  String? country,
  String? postalCode,
  String? state,
  String? specificPersonaGoal,
  bool? isVerified,
  DateTime? creationTimestamp,
  String? photoUrl,
  List<String>? tags,
  String? bio,
   String? website,
  PartnerStatus? partnerStatus,
  Map<String , double>? location ,
  String? geohash

  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      state: state ?? this.state,
      specificPersonaGoal: specificPersonaGoal ?? this.specificPersonaGoal,
      creationTimestamp: creationTimestamp ?? this.creationTimestamp,
      photoUrl: photoUrl ?? this.photoUrl,
      //This is what you filter by (e.g., "grocery", "pharmacy").
      tags: tags ?? this.tags,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      location: location ?? this.location,
      // represents a geographic bounding box. 
      //It is the standard, high-performance way to perform geospatial queries in Firestore
      geohash: geohash ?? this.geohash,
    );
  }

  @override
  List<Object?> get props => [id,role ,email, phone, firstName, lastName, isVerified, address, city, country, postalCode, state, specificPersonaGoal, creationTimestamp, photoUrl, tags, bio, website, partnerStatus, location, geohash];
}