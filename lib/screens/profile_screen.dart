import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; // Importa o ecrã de edição

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // **** NOVA FUNÇÃO ****
  // Função para enviar o e-mail de redefinição de senha
  Future<void> _sendPasswordReset(BuildContext context, String email) async {
    // 1. Mostrar um pop-up de confirmação primeiro
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Text('Será enviado um e-mail para $email com as instruções para redefinir a sua senha. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sim, Enviar E-mail'),
          ),
        ],
      ),
    ) ?? false; // ?? false caso o utilizador feche o diálogo

    if (!confirm) return; // Se o utilizador clicou "Não", paramos aqui.

    // 2. Tentar enviar o e-mail
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail enviado! Verifique a sua caixa de entrada (e spam).'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar e-mail: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          String userName = 'Carregando...';
          String userEmail = user?.email ?? 'Email não disponível';

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? 'Utilizador';
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Cabeçalho do Perfil
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              // Opções do Menu
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar Dados do Perfil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Alterar Senha'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Chama a nova função de redefinição de senha
                  if (user?.email != null) {
                    _sendPasswordReset(context, user!.email!);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red[700]),
                title: Text(
                  'Sair (Logout)',
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}