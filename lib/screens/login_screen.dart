import 'package:eventos_app/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para pegar o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // Função para realizar o login
  Future<void> _signIn() async {
    // Inicia o carregamento
    setState(() {
      _isLoading = true;
    });

    try {
      // Tenta fazer login com o Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se o login for bem-sucedido, a tela principal será mostrada
      // automaticamente pelo StreamBuilder no main.dart
    } on FirebaseAuthException catch (e) {
      // Se ocorrer um erro, mostra uma mensagem para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Ocorreu um erro.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Finaliza o carregamento, mesmo que dê erro
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //  código de UI existente...
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para continuar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
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
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : const Text('Entrar', style: TextStyle(fontSize: 16)),
                ),
              ),
              //  código de UI para o botão de cadastro...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

