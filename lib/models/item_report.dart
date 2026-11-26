/// Jenis laporan pada aplikasi FindIt UNILA.
enum ReportType {
  lost,
  found;

  String get label =>
      this == ReportType.lost ? 'Barang Hilang' : 'Barang Temuan';

  String get shortLabel => this == ReportType.lost ? 'Hilang' : 'Temuan';

  static ReportType fromString(String? value) {
    return value == 'found' ? ReportType.found : ReportType.lost;
  }
}

/// Status siklus hidup laporan barang.
enum ReportStatus {
  active,
  claimed,
  resolved;

  String get label {
    switch (this) {
      case ReportStatus.active:
        return 'Aktif';
      case ReportStatus.claimed:
        return 'Dalam Klaim';
      case ReportStatus.resolved:
        return 'Selesai';
    }
  }

  static ReportStatus fromString(String? value) {
    switch (value) {
      case 'claimed':
        return ReportStatus.claimed;
      case 'resolved':
        return ReportStatus.resolved;
      default:
        return ReportStatus.active;
    }
  }
}

/// Model data laporan barang hilang atau barang temuan.
class ItemReport {
  const ItemReport({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.status,
    required this.colorName,
    required this.description,
    required this.faculty,
    required this.location,
    required this.date,
    required this.reporterName,
    required this.reporterFaculty,
    this.userId,
    this.photoLabel,
    this.photoUrl,
    this.isUserOwned = false,
  });

  final String id;
  final String? userId;
  final String title;
  final String category;
  final ReportType type;
  final ReportStatus status;
  final String colorName;
  final String description;
  final String faculty;
  final String location;
  final DateTime date;
  final String reporterName;
  final String reporterFaculty;
  final String? photoLabel;
  final String? photoUrl;
  final bool isUserOwned;

  factory ItemReport.fromMap(
    Map<String, dynamic> map, {
    String? currentUserId,
  }) {
    final ownerId = map['user_id'] as String?;
    final rawDate = map['incident_date']?.toString() ?? map['created_at']?.toString();
    final parsedDate = DateTime.tryParse(rawDate ?? '') ?? DateTime.now();

    return ItemReport(
      id: map['id'].toString(),
      userId: ownerId,
      title: (map['title'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Lainnya',
      type: ReportType.fromString(map['report_type'] as String?),
      status: ReportStatus.fromString(map['status'] as String?),
      colorName: (map['color_name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      faculty: (map['faculty'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      date: parsedDate,
      reporterName: (map['reporter_name'] as String?) ?? 'Mahasiswa UNILA',
      reporterFaculty: (map['reporter_faculty'] as String?) ?? '',
      photoLabel: map['photo_label'] as String?,
      photoUrl: map['photo_url'] as String?,
      isUserOwned: currentUserId != null && ownerId == currentUserId,
    );
  }

  Map<String, dynamic> toInsertMap(String userId) {
    final isoDate = date.toIso8601String().split('T').first;
    return {
      'user_id': userId,
      'title': title,
      'category': category,
      'report_type': type.name,
      'status': status.name,
      'color_name': colorName,
      'description': description,
      'faculty': faculty,
      'location': location,
      'incident_date': isoDate,
      'photo_label': photoLabel,
      'photo_url': photoUrl,
      'reporter_name': reporterName,
      'reporter_faculty': reporterFaculty,
    };
  }

  ItemReport copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    ReportType? type,
    ReportStatus? status,
    String? colorName,
    String? description,
    String? faculty,
    String? location,
    DateTime? date,
    String? reporterName,
    String? reporterFaculty,
    String? photoLabel,
    String? photoUrl,
    bool? isUserOwned,
  }) {
    return ItemReport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      colorName: colorName ?? this.colorName,
      description: description ?? this.description,
      faculty: faculty ?? this.faculty,
      location: location ?? this.location,
      date: date ?? this.date,
      reporterName: reporterName ?? this.reporterName,
      reporterFaculty: reporterFaculty ?? this.reporterFaculty,
      photoLabel: photoLabel ?? this.photoLabel,
      photoUrl: photoUrl ?? this.photoUrl,
      isUserOwned: isUserOwned ?? this.isUserOwned,
    );
  }
}

/// Hasil pencocokan otomatis (Smart Match) antara barang hilang dan temuan.
class SmartMatchItem {
  const SmartMatchItem({
    required this.report,
    required this.matchedWithTitle,
    required this.scorePercent,
    required this.reason,
  });

  final ItemReport report;
  final String matchedWithTitle;
  final int scorePercent;
  final String reason;
}
