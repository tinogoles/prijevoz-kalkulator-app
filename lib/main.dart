import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prijevoz_kalkulator/screens/login_screen.dart';
import 'package:prijevoz_kalkulator/screens/glavni_navigator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCyB1XlQMLH5DQc_hkrS15pRB-YvovpMpg",
      authDomain: "prijevozkalkulator.firebaseapp.com",
      projectId: "prijevozkalkulator",
      storageBucket: "prijevozkalkulator.firebasestorage.app",
      messagingSenderId: "922321976582",
      appId: "1:922321976582:web:39e85da2503409f50b7287",
    ),
  );
  runApp(const PrijevozKalkulatorApp());
}

class PrijevozKalkulatorApp extends StatelessWidget {
  const PrijevozKalkulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Prijevoza HR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          secondary: const Color(0xFFEA580C),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            return user == null ? const LoginScreen() : const GlavniNavigatorScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
