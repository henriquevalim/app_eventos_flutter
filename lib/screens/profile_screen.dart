import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_screen.dart'; // Importa o novo ecrã

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        automaticallyImplyLeading: false, // Remove a seta de voltar na barra inferior
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Usamos StreamBuilder para que o perfil atualize automaticamente
        // assim que o utilizador voltar do ecrã de edição.
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
                  // Navega para o ecrã de edição
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
                  // Futuro: Implementar alteração de senha
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade em breve!')),
                  );
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