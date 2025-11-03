import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define um modelo simples para uma mensagem de chat.
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // ESTE É O "CÉREBRO" DO  ASSISTENTE
  // É aqui q defino o seu papel e conhecimento.
  final String _systemPrompt = """
  Você é o "EvenTech Assistente", o assistente virtual amigável e profissional da EvenTech,
  uma empresa de estruturas para eventos no Rio Grande do Sul.

  Seu objetivo é tirar dúvidas sobre os serviços e ajudar os clientes.
  Seja sempre educado e direto ao ponto.

  VOCÊ NÃO PODE AGENDAR SERVIÇOS. Se o cliente pedir para agendar,
  instrua-o a usar o ecrã "Agendar" ou "Calendário" na aplicação.

  Aqui está a lista dos seus serviços, use-os como base para as suas respostas:

  - Montagem de Palco: A partir de R\$ 1800. Vários tamanhos (6x4m, 8x6m, 10x8m).
  - Deck e Pisos Elevados: A partir de R\$ 1500. Várias áreas (25m², 50m², 100m²).
  - Sistema de Som: A partir de R\$ 800. Opções para pequeno, médio e grande porte.
  - Iluminação Profissional: A partir de R\$ 750. Opções de iluminação de pista, cénica ou completa.
  - Tenda Estruturada: A partir de R\$ 900. Opções de 5x5m e 10x10m.
  - Painel de LED: A partir de R\$ 1500. Vários tamanhos (3x2m, 4x3m, 5x3m).
  - Operador de Som (Técnico): Preço fixo de R\$ 500 por evento.
  - Operador de Luz (Iluminador): Preço fixo de R\$ 450 por evento.

  Para serviços com variações, sempre informe o preço "A partir de" e sugira
  que o cliente veja os detalhes e opções no ecrã do serviço.

  Não responda a perguntas que não tenham relação com eventos ou com os serviços da empresa.
  """;

  // Função chamada quando o utilizador prime "Enviar"
  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    // Adiciona a mensagem do utilizador ao ecrã
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true; // Mostra o indicador de "a pensar..."
    });

    _controller.clear();

    try {
      // Configurações da API do Gemini
      // A chave API é deixada em branco, pois será fornecida pelo ambiente
      const apiKey = "AIzaSyBiaS8qdEXdWThhSze2K9sluI4hI11Zyt8";
      const apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$apiKey";

      final headers = {'Content-Type': 'application/json'};

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': text} // A pergunta do utilizador
            ]
          }
        ],
        // Inclui o "contexto" da sua empresa em cada chamada
        'systemInstruction': {
          'parts': [
            {'text': _systemPrompt}
          ]
        },
      });

      // Faz a chamada à API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Extrai a resposta da IA
        final aiResponse = result['candidates'][0]['content']['parts'][0]['text'];

        // Adiciona a resposta da IA ao ecrã
        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUser: false));
        });
      } else {
        // Trata erros da API
        _showError('Erro ao contactar a IA: ${response.body}');
      }
    } catch (e) {
      // Trata erros de rede
      _showError('Erro de conexão: $e');
    } finally {
      setState(() {
        _isLoading = false; // Esconde o indicador de "a pensar..."
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(ChatMessage(text: "Desculpe, ocorreu um erro. Tente novamente.", isUser: false));
    });
    // Mostra o erro detalhado na consola de depuração
    debugPrint(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de Assistência'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Área das mensagens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true, // As mensagens novas aparecem em baixo
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Indicador de "a pensar..."
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text("A pensar...")
                ],
              ),
            ),
          // Área de digitar
          _buildTextInputArea(),
        ],
      ),
    );
  }

  // Constrói a "bolha" de mensagem
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: message.isUser ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Constrói a barra de "digite a sua mensagem"
  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Digite a sua mensagem...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage, // Desativa o botão enquanto a IA pensa
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
