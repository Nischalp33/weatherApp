import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:weather_m/provider/location_provider.dart';
import 'package:weather_m/screens/home_screen.dart';
import 'package:weather_m/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isSkipPressed = await _checkSkipStatus();

  runApp(MyApp(isSkipPressed: isSkipPressed));
}

//check if the skip button is already pressed

Future<bool> _checkSkipStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('skipPressed') ?? false;
}

class MyApp extends StatelessWidget {
  final bool isSkipPressed;

  const MyApp({super.key, required this.isSkipPressed});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        home: isSkipPressed ? const HomeScreen() : const SplashScreen(),
      ),
    );
  }
}
