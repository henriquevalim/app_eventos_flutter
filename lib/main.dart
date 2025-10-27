import 'package:eventos_app/screens/login_screen.dart';
import 'package:eventos_app/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// 1. Importa o pacote de inicialização de data
import 'package:intl/date_symbol_data_local.dart';

void main() async { // 2. Transforme a função main em 'async'
  // Garante que o Flutter está pronto antes de executar código nativo.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase.
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);
  // Executa a aplicação.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvenTech',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Usa um StreamBuilder para "ouvir" o estado da autenticação em tempo real.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto a verificação está a acontecer, mostra um ecrã de carregamento.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // Se o snapshot tiver dados (um utilizador), o utilizador está logado.
          if (snapshot.hasData) {
            return const MainScreen(); // Vai para o ecrã principal.
          }
          // Caso contrário, o utilizador não está logado.
          return const LoginScreen(); // Vai para o ecrã de login.
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

