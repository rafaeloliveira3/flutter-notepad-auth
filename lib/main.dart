import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

//database password: PDMFatec@127
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hwhxhgdzfalamosvzstm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3aHhoZ2R6ZmFsYW1vc3Z6c3RtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2MzIzMzIsImV4cCI6MjA5NTIwODMzMn0.PqMBRX0neGh3SpkZIFg-ogLm15su3-E8EfspeJ4lqQY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getHome() {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Notes',
      debugShowCheckedModeBanner: false,
      home: _getHome(),
    );
  }
}
