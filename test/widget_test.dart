import 'package:flutter_test/flutter_test.dart';

import 'package:findit_unila/app.dart';
import 'package:findit_unila/core/config/supabase_config.dart';
import 'package:findit_unila/models/item_report.dart';
import 'package:findit_unila/pages/login_page.dart';
import 'package:findit_unila/pages/splash_page.dart';

void main() {
  testWidgets('Splash screen menampilkan identitas FindIt UNILA dan menuju Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const FindItUnilaApp(
        initialHome: SplashPage(duration: Duration(milliseconds: 50)),
      ),
    );

    expect(find.text('FindIt UNILA'), findsOneWidget);
    expect(find.text('Lost Something? Find It Here!'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });

  testWidgets('Login masuk ke MainShell dengan 5 menu navigasi bawah',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FindItUnilaApp(initialHome: LoginPage()));

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Cari'), findsOneWidget);
    expect(find.text('Lapor'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Pindah ke tab Cari
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();
    expect(find.text('Cari Barang'), findsOneWidget);

    // Pindah ke tab Lapor
    await tester.tap(find.text('Lapor'));
    await tester.pumpAndSettle();
    expect(find.text('Buat Laporan'), findsOneWidget);

    // Pindah ke tab Riwayat
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat Aktivitas'), findsOneWidget);

    // Pindah ke tab Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profil Saya'), findsOneWidget);
  });

  test('Konfigurasi Supabase nonaktif tanpa --dart-define dan model parsing aman', () {
    expect(SupabaseConfig.isConfigured, isFalse);

    final report = ItemReport.fromMap(
      {
        'id': 'rep-test-1',
        'user_id': 'usr-1',
        'title': 'KTM UNILA',
        'category': 'Dokumen & Kartu',
        'report_type': 'found',
        'status': 'active',
        'color_name': 'Biru',
        'description': 'Ditemukan di Gedung H.',
        'faculty': 'Fakultas Teknik (FT)',
        'location': 'Gedung H',
        'incident_date': '2026-11-26',
        'reporter_name': 'Rafi',
        'reporter_faculty': 'Fakultas Teknik (FT)',
      },
      currentUserId: 'usr-1',
    );

    expect(report.type, ReportType.found);
    expect(report.status, ReportStatus.active);
    expect(report.isUserOwned, isTrue);
  });
}
