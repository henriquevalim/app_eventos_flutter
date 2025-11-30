import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Tenta criar o utilizador
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se chegar aqui, funcionou perfeitamente.

    } on FirebaseAuthException catch (e) {
      // Erros REAIS do Firebase (email duplicado, senha fraca, etc.)
      String errorMessage = 'Ocorreu um erro no cadastro.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está a ser usado.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'A senha é muito fraca.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O e-mail é inválido.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
      // Se foi um erro real de auth, paramos por aqui.
      setState(() { _isLoading = false; });
      return;

    } catch (e) {
      // Se cair aqui, pode ser o BUG do emulador.
      // apenas loga o aviso e deixamos o código continuar para a verificação abaixo.
      debugPrint("Aviso: Possível erro falso-positivo do emulador capturado: $e");
    }

    // 2. VERIFICAÇÃO DE SEGURANÇA E GRAVAÇÃO NO FIRESTORE
    // Independentemente de ter dado o erro "Pigeon" ou não, verifica:
    // "Existe alguém logado agora?"
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // SIM! O utilizador foi criado (mesmo que tenha dado erro no meio do caminho).
      // Então, garantir que o nome é salvo no Firestore.
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': Timestamp.now(),
          'role': 'client',
        }, SetOptions(merge: true)); // 'merge' evita sobrescrever se já existir algo

        // Tudo certo, fecha o ecrã de cadastro.
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (firestoreError) {
        debugPrint("Erro ao salvar no Firestore: $firestoreError");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conta criada, mas houve erro ao salvar o nome.'), backgroundColor: Colors.orange));
        }
      }
    }

    // Garante que o loading pare sempre no final de tudo.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}