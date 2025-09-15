import 'package:flutter/material.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Agendamentos', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(text: 'FUTUROS'),
              Tab(text: 'PASSADOS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Conteúdo da Aba "Futuros"
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                AgendamentoCard(
                  servico: 'DJ Profissional',
                  data: '25 de Dezembro, 2024',
                  horario: '22:00',
                  status: 'Confirmado',
                  statusColor: Colors.green,
                ),
                SizedBox(height: 12),
                AgendamentoCard(
                  servico: 'Iluminação de Pista',
                  data: '15 de Janeiro, 2025',
                  horario: '19:00',
                  status: 'Pendente',
                  statusColor: Colors.orange,
                ),
              ],
            ),
            // Conteúdo da Aba "Passados"
            const Center(
              child: Text('Nenhum agendamento passado.'),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizável para os cards de agendamento
class AgendamentoCard extends StatelessWidget {
  final String servico;
  final String data;
  final String horario;
  final String status;
  final Color statusColor;

  const AgendamentoCard({
    super.key,
    required this.servico,
    required this.data,
    required this.horario,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(servico, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Data: $data', style: const TextStyle(color: Colors.grey)),
            Text('Horário: $horario', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
