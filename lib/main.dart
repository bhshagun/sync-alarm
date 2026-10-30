import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/pairing_screen.dart';
import 'services/alarm_service.dart';
import 'services/supabase_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent device orientation rotation to keep clean layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Init services
  await SupabaseService().init();
  AlarmService().init(navigatorKey);

  runApp(const CoupleAlarmApp());
}

class CoupleAlarmApp extends StatelessWidget {
  const CoupleAlarmApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaired = SupabaseService().pairCode != null;

    return MaterialApp(
      title: 'SyncAlarm for Couples',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF13111C),
        primaryColor: const Color(0xFFFF5E7E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5E7E),
          secondary: Color(0xFFFF9966),
          surface: Color(0xFF1E1B2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: isPaired ? const HomeScreen() : const PairingScreen(),
    );
  }
}
