import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/dummy_data.dart';
import '../models/claim_request.dart';
import '../models/item_report.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

/// State utama aplikasi FindIt UNILA.
/// Menggunakan Supabase jika dikonfigurasi via --dart-define, dan fallback ke data dummy jika offline.
class AppState extends ChangeNotifier {
  AppState({SupabaseService? supabaseService})
      : _supabase = supabaseService ?? SupabaseService.instance,
        _currentUser = DummyData.defaultUser,
        _reports = DummyData.initialReports(),
        _claims = DummyData.initialClaims();

  final SupabaseService _supabase;
  StreamSubscription<AuthState>? _authSubscription;

  UserProfile _currentUser;
  bool _isLoggedIn = false;
  bool _handlingManualAuth = false;
  bool _pendingDeepLinkSignIn = false;
  String? _pendingAuthError;
  List<ItemReport> _reports;
  List<ClaimRequest> _claims;

  int _currentTabIndex = 0;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedFaculty;
  ReportType? _selectedType;

  UserProfile get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isUsingSupabase => _supabase.isActive;
  bool get pendingDeepLinkSignIn => _pendingDeepLinkSignIn;
  String? get pendingAuthError => _pendingAuthError;
  int get currentTabIndex => _currentTabIndex;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedFaculty => _selectedFaculty;
  ReportType? get selectedType => _selectedType;

  void startAuthListener() {
    if (!_supabase.isActive || _authSubscription != null) return;
    _authSubscription = _supabase.onAuthStateChange.listen(
      (authState) {
        unawaited(_handleAuthStateEvent(authState));
      },
      onError: (Object error, StackTrace stackTrace) {
        _pendingAuthError = _supabase.formatAuthError(error);
        notifyListeners();
      },
    );
  }

  bool consumeDeepLinkSignIn() {
    if (!_pendingDeepLinkSignIn) return false;
    _pendingDeepLinkSignIn = false;
    return true;
  }

  String? consumeAuthError() {
    final error = _pendingAuthError;
    _pendingAuthError = null;
    return error;
  }

  Future<void> _handleAuthStateEvent(AuthState authState) async {
    if (authState.event == AuthChangeEvent.signedIn &&
        authState.session != null) {
      if (_handlingManualAuth || _isLoggedIn) return;
      try {
        final user = authState.session!.user;
        _currentUser = await _supabase.ensureProfileForUser(user);
        _isLoggedIn = true;
        _currentTabIndex = 0;
        _pendingDeepLinkSignIn = true;
        await _syncRemoteData(user.id);
        notifyListeners();
      } catch (e) {
        _pendingAuthError = _supabase.formatAuthError(e);
        notifyListeners();
      }
      return;
    }

    if (authState.event == AuthChangeEvent.signedOut &&
        !_handlingManualAuth &&
        _isLoggedIn) {
      _isLoggedIn = false;
      _reports = [];
      _claims = [];
      _currentUser = DummyData.defaultUser;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  List<ItemReport> get allReports => List.unmodifiable(_reports);

  List<ItemReport> get recentReports {
    final sorted = List<ItemReport>.from(_reports)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<ItemReport> get filteredReports {
    final query = _searchQuery.trim().toLowerCase();
    return recentReports.where((item) {
      if (_selectedType != null && item.type != _selectedType) return false;
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      if (_selectedFaculty != null && item.faculty != _selectedFaculty) {
        return false;
      }
      if (query.isNotEmpty) {
        final searchable =
            '${item.title} ${item.description} ${item.colorName} ${item.location} ${item.faculty} ${item.category}'
                .toLowerCase();
        if (!searchable.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  List<ItemReport> get userReports =>
      recentReports.where((item) => item.isUserOwned).toList();

  List<ClaimRequest> get userClaims {
    final sorted = List<ClaimRequest>.from(_claims)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Menghasilkan rekomendasi Smart Match berdasarkan kemiripan kategori, warna, dan fakultas.
  List<SmartMatchItem> get smartMatches {
    final matches = <SmartMatchItem>[];
    final userLost = _reports.where(
      (r) => r.isUserOwned && r.type == ReportType.lost,
    );
    final candidateFound = _reports.where(
      (r) =>
          !r.isUserOwned &&
          r.type == ReportType.found &&
          r.status == ReportStatus.active,
    );

    for (final lost in userLost) {
      for (final found in candidateFound) {
        if (lost.category == found.category) {
          int score = 70;
          final reasons = <String>['Kategori sama (${found.category})'];
          if (lost.colorName.toLowerCase() == found.colorName.toLowerCase()) {
            score += 15;
            reasons.add('warna ${found.colorName.toLowerCase()}');
          }
          if (lost.faculty == found.faculty) {
            score += 10;
            reasons.add('area fakultas sama');
          }
          matches.add(
            SmartMatchItem(
              report: found,
              matchedWithTitle: lost.title,
              scorePercent: score.clamp(60, 98),
              reason: reasons.join(', '),
            ),
          );
        }
      }
    }

    if (matches.length < 2) {
      for (final item in _reports) {
        final alreadyIncluded = matches.any((m) => m.report.id == item.id);
        if (!alreadyIncluded &&
            !item.isUserOwned &&
            item.status == ReportStatus.active) {
          matches.add(
            SmartMatchItem(
              report: item,
              matchedWithTitle: item.faculty,
              scorePercent: 84,
              reason: 'Lokasi dekat aktivitas ${_currentUser.faculty}',
            ),
          );
        }
        if (matches.length >= 3) break;
      }
    }

    return matches;
  }

  bool hasClaimedItem(String itemId) {
    return _claims.any((claim) => claim.itemId == itemId);
  }

  /// Memulihkan sesi Supabase apabila user sudah login sebelumnya.
  Future<bool> restoreSessionIfAvailable() async {
    if (!_supabase.isActive) return false;
    final authUser = _supabase.currentAuthUser;
    if (authUser == null) return false;

    try {
      final profile = await _supabase.fetchProfile(authUser.id);
      if (profile != null) {
        _currentUser = profile;
      }
      _isLoggedIn = true;
      await _syncRemoteData(authUser.id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _syncRemoteData(String userId) async {
    final results = await Future.wait([
      _supabase.fetchReports(currentUserId: userId),
      _supabase.fetchUserClaims(userId),
    ]);
    _reports = results[0] as List<ItemReport>;
    _claims = results[1] as List<ClaimRequest>;
  }

  Future<String?> login({
    required String email,
    String password = '',
  }) async {
    if (_supabase.isActive) {
      _handlingManualAuth = true;
      try {
        final profile = await _supabase.signIn(
          email: email,
          password: password,
        );
        _currentUser = profile;
        _isLoggedIn = true;
        _currentTabIndex = 0;
        await _syncRemoteData(profile.id);
        notifyListeners();
        return null;
      } catch (e) {
        return _supabase.formatAuthError(e);
      } finally {
        _handlingManualAuth = false;
      }
    }

    final cleanEmail = email.trim();
    if (cleanEmail.isNotEmpty) {
      final derivedName = _deriveNameFromEmail(cleanEmail);
      _currentUser = _currentUser.copyWith(
        email: cleanEmail,
        fullName: cleanEmail == DummyData.defaultUser.email
            ? DummyData.defaultUser.fullName
            : derivedName,
      );
    }
    _isLoggedIn = true;
    _currentTabIndex = 0;
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String faculty,
    String password = '',
  }) async {
    if (_supabase.isActive) {
      _handlingManualAuth = true;
      try {
        final profile = await _supabase.signUp(
          fullName: fullName,
          email: email,
          faculty: faculty,
          password: password,
        );
        if (profile == null) {
          return 'VERIFICATION_REQUIRED';
        }
        _currentUser = profile;
        _isLoggedIn = true;
        _currentTabIndex = 0;
        await _syncRemoteData(profile.id);
        notifyListeners();
        return null;
      } catch (e) {
        return _supabase.formatAuthError(e);
      } finally {
        _handlingManualAuth = false;
      }
    }

    _currentUser = UserProfile(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      faculty: faculty,
      npm: '2315061099',
      phone: '0812-0000-1122',
      smartMatchNotifications: true,
    );
    _isLoggedIn = true;
    _currentTabIndex = 0;
    notifyListeners();
    return null;
  }

  Future<String?> resendConfirmationEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return 'Masukkan alamat email yang valid terlebih dahulu.';
    }
    if (!_supabase.isActive) {
      return 'Kirim ulang email verifikasi memerlukan konfigurasi Supabase (--dart-define).';
    }
    try {
      await _supabase.resendConfirmationEmail(cleanEmail);
      return null;
    } catch (e) {
      return _supabase.formatAuthError(e);
    }
  }

  Future<void> logout() async {
    if (_supabase.isActive) {
      try {
        await _supabase.signOut();
      } catch (_) {}
      _reports = [];
      _claims = [];
      _currentUser = DummyData.defaultUser;
    }
    _isLoggedIn = false;
    _currentTabIndex = 0;
    notifyListeners();
  }

  void setTab(int index) {
    if (_currentTabIndex == index) return;
    _currentTabIndex = index;
    notifyListeners();
  }

  void openSearchWithQuery(String query) {
    _searchQuery = query;
    _currentTabIndex = 1;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedFaculty(String? faculty) {
    _selectedFaculty = faculty;
    notifyListeners();
  }

  void setSelectedType(ReportType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void resetSearchFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedFaculty = null;
    _selectedType = null;
    notifyListeners();
  }

  Future<String?> addReport({
    required ReportType type,
    required String title,
    required String category,
    required String colorName,
    required String description,
    required String faculty,
    required String location,
    required DateTime date,
    String? photoLabel,
  }) async {
    final draft = ItemReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser.id,
      title: title.trim(),
      category: category,
      type: type,
      status: ReportStatus.active,
      colorName: colorName.trim(),
      description: description.trim(),
      faculty: faculty,
      location: location.trim(),
      date: date,
      reporterName: _currentUser.fullName,
      reporterFaculty: _currentUser.faculty,
      photoLabel: photoLabel,
      isUserOwned: true,
    );

    if (_supabase.isActive) {
      try {
        final saved = await _supabase.createReport(
          report: draft,
          userId: _currentUser.id,
        );
        _reports.insert(0, saved);
        notifyListeners();
        return null;
      } catch (e) {
        return 'Gagal menyimpan laporan ke Supabase: $e';
      }
    }

    _reports.insert(0, draft);
    notifyListeners();
    return null;
  }

  Future<String?> updateReportStatus(
    String reportId,
    ReportStatus status,
  ) async {
    if (_supabase.isActive) {
      try {
        await _supabase.updateReportStatus(reportId: reportId, status: status);
      } catch (e) {
        return 'Gagal memperbarui status di Supabase: $e';
      }
    }

    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return null;
    _reports[index] = _reports[index].copyWith(status: status);
    notifyListeners();
    return null;
  }

  Future<String?> submitClaim({
    required ItemReport item,
    required String verificationNote,
    required String contactInfo,
  }) async {
    if (_supabase.isActive) {
      try {
        final savedClaim = await _supabase.createClaim(
          item: item,
          claimantId: _currentUser.id,
          claimantName: _currentUser.fullName,
          verificationNote: verificationNote,
          contactInfo: contactInfo,
        );
        _claims.insert(0, savedClaim);
        final index = _reports.indexWhere((r) => r.id == item.id);
        if (index != -1 && _reports[index].status == ReportStatus.active) {
          _reports[index] =
              _reports[index].copyWith(status: ReportStatus.claimed);
        }
        notifyListeners();
        return null;
      } catch (e) {
        return 'Gagal mengirim klaim ke Supabase: $e';
      }
    }

    final claim = ClaimRequest(
      id: 'clm-${DateTime.now().millisecondsSinceEpoch}',
      itemId: item.id,
      itemTitle: item.title,
      itemType: item.type,
      itemCategory: item.category,
      itemLocation: item.location,
      itemFaculty: item.faculty,
      claimantName: _currentUser.fullName,
      verificationNote: verificationNote.trim(),
      contactInfo: contactInfo.trim(),
      createdAt: DateTime.now(),
      status: ClaimStatus.pending,
    );
    _claims.insert(0, claim);

    final index = _reports.indexWhere((r) => r.id == item.id);
    if (index != -1 && _reports[index].status == ReportStatus.active) {
      _reports[index] = _reports[index].copyWith(status: ReportStatus.claimed);
    }
    notifyListeners();
    return null;
  }

  Future<String?> updateProfile({
    required String fullName,
    required String faculty,
    required String phone,
  }) async {
    if (_supabase.isActive) {
      try {
        _currentUser = await _supabase.updateProfile(
          userId: _currentUser.id,
          fullName: fullName,
          faculty: faculty,
          phone: phone,
        );
        notifyListeners();
        return null;
      } catch (e) {
        return 'Gagal memperbarui profil di Supabase: $e';
      }
    }

    _currentUser = _currentUser.copyWith(
      fullName: fullName.trim(),
      faculty: faculty,
      phone: phone.trim(),
    );
    notifyListeners();
    return null;
  }

  Future<void> toggleSmartMatchNotifications(bool value) async {
    _currentUser = _currentUser.copyWith(smartMatchNotifications: value);
    notifyListeners();

    if (_supabase.isActive) {
      try {
        await _supabase.updateSmartMatchNotifications(
          userId: _currentUser.id,
          enabled: value,
        );
      } catch (_) {}
    }
  }

  String _deriveNameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local
        .split(RegExp(r'[._-]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .toList();
    return parts.isEmpty ? 'Mahasiswa UNILA' : parts.join(' ');
  }
}

/// InheritedNotifier untuk membagikan AppState ke seluruh widget tree.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope tidak ditemukan pada widget tree.');
    return scope!.notifier!;
  }
}
