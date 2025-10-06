import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O conteúdo visual da tela permanece o mesmo de antes
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Agendamentos'),
          automaticallyImplyLeading: false, // Remove o botão de voltar
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximos'),
              Tab(text: 'Passados'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Conteúdo para Próximos Agendamentos
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum agendamento próximo.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
            // Conteúdo para Agendamentos Passados
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Seu histórico de eventos aparecerá aqui.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
