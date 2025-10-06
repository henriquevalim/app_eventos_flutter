import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o usuário logado atualmente
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user.email ?? 'Email não disponível'),
            ),
            const Divider(),
          ],
          // Adicione aqui outros campos do perfil se desejar
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações da Conta'),
            onTap: () {
              // Navegar para uma tela de configurações, se houver
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text(
              'Sair (Logout)',
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () async {
              // Função para fazer logout
              await FirebaseAuth.instance.signOut();
              // O StreamBuilder no main.dart cuidará de redirecionar para o login
            },
          ),
        ],
      ),
    );
  }
}

