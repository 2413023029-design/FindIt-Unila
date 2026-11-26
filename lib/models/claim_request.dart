import 'item_report.dart';

/// Status pengajuan klaim barang oleh pengguna.
enum ClaimStatus {
  pending,
  approved,
  rejected;

  String get label {
    switch (this) {
      case ClaimStatus.pending:
        return 'Menunggu Verifikasi';
      case ClaimStatus.approved:
        return 'Disetujui';
      case ClaimStatus.rejected:
        return 'Ditolak';
    }
  }

  static ClaimStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.pending;
    }
  }
}

/// Model data pengajuan klaim atau konfirmasi penemuan barang.
class ClaimRequest {
  const ClaimRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemType,
    required this.itemCategory,
    required this.itemLocation,
    required this.itemFaculty,
    required this.claimantName,
    required this.verificationNote,
    required this.contactInfo,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String itemId;
  final String itemTitle;
  final ReportType itemType;
  final String itemCategory;
  final String itemLocation;
  final String itemFaculty;
  final String claimantName;
  final String verificationNote;
  final String contactInfo;
  final DateTime createdAt;
  final ClaimStatus status;

  factory ClaimRequest.fromMap(Map<String, dynamic> map) {
    final item = map['item_reports'] as Map<String, dynamic>?;
    return ClaimRequest(
      id: map['id'].toString(),
      itemId: map['item_id'].toString(),
      itemTitle: (item?['title'] as String?) ?? 'Laporan Barang',
      itemType: ReportType.fromString(item?['report_type'] as String?),
      itemCategory: (item?['category'] as String?) ?? 'Lainnya',
      itemLocation: (item?['location'] as String?) ?? '-',
      itemFaculty: (item?['faculty'] as String?) ?? '-',
      claimantName: (map['claimant_name'] as String?) ?? 'Mahasiswa UNILA',
      verificationNote: (map['verification_note'] as String?) ?? '',
      contactInfo: (map['contact_info'] as String?) ?? '',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: ClaimStatus.fromString(map['status'] as String?),
    );
  }

  ClaimRequest copyWith({ClaimStatus? status}) {
    return ClaimRequest(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      itemType: itemType,
      itemCategory: itemCategory,
      itemLocation: itemLocation,
      itemFaculty: itemFaculty,
      claimantName: claimantName,
      verificationNote: verificationNote,
      contactInfo: contactInfo,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
