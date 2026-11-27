import 'package:material_ui/material_ui.dart';

import 'core/constants/unila_data.dart';
import 'core/theme/app_theme.dart';
import 'pages/main_shell.dart';
import 'pages/splash_page.dart';
import 'state/app_state.dart';

/// Root widget aplikasi FindIt UNILA.
class FindItUnilaApp extends StatefulWidget {
  const FindItUnilaApp({
    super.key,
    this.initialHome,
  });

  /// Opsional untuk pengujian widget agar dapat langsung menuju halaman tertentu.
  final Widget? initialHome;

  @override
  State<FindItUnilaApp> createState() => _FindItUnilaAppState();
}

class _FindItUnilaAppState extends State<FindItUnilaApp> {
  final AppState _appState = AppState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _appState.startAuthListener();
    _appState.addListener(_handleAppStateChanges);
  }

  void _handleAppStateChanges() {
    final authError = _appState.consumeAuthError();
    if (authError != null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(authError),
          duration: const Duration(seconds: 6),
        ),
      );
    }

    if (_appState.consumeDeepLinkSignIn() && widget.initialHome == null) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (route) => false,
      );
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Email berhasil diverifikasi! Selamat datang di FindIt UNILA.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_handleAppStateChanges);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: UnilaData.appName,
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        home: widget.initialHome ?? const SplashPage(),
      ),
    );
  }
}
