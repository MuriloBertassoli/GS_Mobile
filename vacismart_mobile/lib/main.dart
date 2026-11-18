import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'widgets/vacismart_widgets.dart';

void main() {
  runApp(const VaciSmartApp());
}

class VaciSmartApp extends StatelessWidget {
  const VaciSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaciSmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: VaciSmartColors.primaria),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}