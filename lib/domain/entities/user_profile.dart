class UserProfile {
  UserProfile({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.issuedAt,
  });

  final String uid;
  final String? phoneNumber;
  final String? displayName;
  final String? email;
  final DateTime? issuedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        phoneNumber: json['phoneNumber'] as String?,
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        issuedAt: DateTime.tryParse(json['issuedAt'] as String? ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'email': email,
        'issuedAt': issuedAt?.toIso8601String(),
      };
}

