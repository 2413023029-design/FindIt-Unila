import 'package:material_ui/material_ui.dart';

import 'core/constants/unila_data.dart';
import 'core/theme/app_theme.dart';
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

  @override
  void dispose() {
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
        theme: AppTheme.lightTheme,
        home: widget.initialHome ?? const SplashPage(),
      ),
    );
  }
}
