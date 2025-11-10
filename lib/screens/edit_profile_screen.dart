import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carrega os dados atuais do utilizador para preencher o formulário
  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _nameController.text = doc.data()?['name'] ?? '';
        });
      }
    }
  }

  // Função para salvar as alterações no Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        // Aqui poderíamos adicionar outros campos no futuro (telefone, etc.)
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Volta para o ecrã anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo Email (Apenas leitura, para informação)
              TextFormField(
                initialValue: user?.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5), // Cinza claro para indicar que não é editável
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para alterar o e-mail, entre em contacto com o suporte.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}