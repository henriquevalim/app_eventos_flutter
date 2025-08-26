import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; // Importa a tela de login
import 'screens/main_screen.dart';  // Importa a tela principal (com a barra de navegação)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Cor de fundo padrão
        fontFamily: 'Inter', // Recomendo adicionar a fonte Inter ao projeto
      ),
      // Define a tela inicial
      initialRoute: '/',
      // Define as rotas nomeadas para facilitar a navegação
      routes: {
        '/': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}