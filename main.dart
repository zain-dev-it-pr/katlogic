import 'package:flutter/material.dart';
import 'package:katlogic/screen/home/home_screen.dart';
import 'package:katlogic/screen/spalsh/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KatLogicApp());
}

class KatLogicApp extends StatelessWidget {
  const KatLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KATLOGIC AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.cyanAccent,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
