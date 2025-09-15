import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Virtual', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ChatMessage(
                  text: 'Olá! Como posso ajudar com os serviços para o seu evento hoje?',
                  isFromUser: false,
                ),
                ChatMessage(
                  text: 'Gostaria de saber se o pacote de DJ inclui o equipamento de som.',
                  isFromUser: true,
                ),
                ChatMessage(
                  text: 'Ótima pergunta! O pacote "DJ Profissional" foca na performance musical. O "Sistema de Som" é um pacote separado, mas podemos criar um combo com desconto para você!',
                  isFromUser: false,
                ),
              ],
            ),
          ),
          // Campo de digitação
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para a bolha de mensagem
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isFromUser;

  const ChatMessage({super.key, required this.text, required this.isFromUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFromUser ? Colors.indigo : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: isFromUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
