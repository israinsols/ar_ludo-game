import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/tournament_provider.dart';
import 'screens/home_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/game_board_screen.dart';
import 'screens/win_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/scoreboard_screen.dart';
import 'screens/tournament_setup_screen.dart';
import 'screens/tournament_dashboard_screen.dart';
import 'screens/tournament_winner_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const LudoApp());
}

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: MaterialApp(
        title: 'Ludo Game',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF7c3aed),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0a0a1a),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/': (_) => const HomeScreen(),
          '/player_setup': (_) => const PlayerSetupScreen(),
          '/game_board': (_) => const GameBoardScreen(),
          '/win': (_) => const WinScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/scoreboard': (_) => const ScoreboardScreen(),
          '/tournament_setup': (_) => const TournamentSetupScreen(),
          '/tournament_dashboard': (_) => const TournamentDashboardScreen(),
          '/tournament_winner': (_) => const TournamentWinnerScreen(),
          '/privacy_policy': (_) => const PrivacyPolicyScreen(),
        },
      ),
    );
  }
}
