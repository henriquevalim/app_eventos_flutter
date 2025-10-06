import 'package:eventos_app/screens/login_screen.dart';
import 'package:eventos_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Conecta com o projeto Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicia o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      // Controla qual tela mostrar baseado no status de login
      home: StreamBuilder<User?>(
        // Conecta com o stream de autenticação do Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica o status, mostra uma tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Se o snapshot tem um usuário (usuário logado)
          if (snapshot.hasData) {
            // Mostra a tela principal do app
            return const MainScreen();
          }
          // Se não tem um usuário (usuário deslogado)
          return const LoginScreen();
        },
      ),
    );
  }
}

