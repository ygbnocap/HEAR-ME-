// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Скрытая строка состояния и панель навигации
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Принудительная альбомная ориентация
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const LoudQuestionApp());
}

class LoudQuestionApp extends StatelessWidget {
  const LoudQuestionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Как слышно?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B69DB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/start': (context) => const StartScreen(),
      },
    );
  }
}