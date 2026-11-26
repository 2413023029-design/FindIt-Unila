/// Model profil pengguna FindIt UNILA.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.faculty,
    required this.npm,
    required this.phone,
    this.smartMatchNotifications = true,
  });

  final String id;
  final String fullName;
  final String email;
  final String faculty;
  final String npm;
  final String phone;
  final bool smartMatchNotifications;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'].toString(),
      fullName: (map['full_name'] as String?) ?? 'Mahasiswa UNILA',
      email: (map['email'] as String?) ?? '',
      faculty: (map['faculty'] as String?) ?? 'Fakultas Teknik (FT)',
      npm: (map['npm'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      smartMatchNotifications:
          (map['smart_match_notifications'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'faculty': faculty,
      'npm': npm,
      'phone': phone,
      'smart_match_notifications': smartMatchNotifications,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? faculty,
    String? npm,
    String? phone,
    bool? smartMatchNotifications,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      npm: npm ?? this.npm,
      phone: phone ?? this.phone,
      smartMatchNotifications:
          smartMatchNotifications ?? this.smartMatchNotifications,
    );
  }
}
