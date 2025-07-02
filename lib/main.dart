import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/about_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('predictions');

  runApp(const WasteClassifierApp());
}

class WasteClassifierApp extends StatelessWidget {
  const WasteClassifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Recycle Smart',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.green,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (_) => const HomeScreen(),
              '/history': (_) => const HistoryScreen(),
              '/charts': (_) => const ChartScreen(),
              '/tips': (_) => const TipsScreen(),
              '/about': (_) => const AboutScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
