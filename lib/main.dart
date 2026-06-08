// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Função para verificar se há uma sessão de utilizador guardada
  Future<User?> _getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return User.fromJson(jsonDecode(userDataString));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'Relber e Alan',
      theme: ThemeData(
        brightness: Brightness.dark,
        // ... (o resto do seu tema)
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
      debugShowCheckedModeBanner: false,
  home: FutureBuilder<User?>(
        future: _getSavedUser(),
        builder: (context, snapshot) {
          // Enquanto espera, mostra um ecrã de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Se encontrou um utilizador guardado, vai para a HomeScreen
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(user: snapshot.data!);
          }
          // Se não, vai para a LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
