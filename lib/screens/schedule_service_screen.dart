import 'package:flutter/material.dart';

class ScheduleServiceScreen extends StatelessWidget {
  // daicionando o construtor para receber o nome do serviço
  final String serviceName;

  const ScheduleServiceScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Serviço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto que já vem preenchido e desabilitado
            TextFormField(
              initialValue: serviceName,
              readOnly: true, // Impede que o usuário edite
              decoration: const InputDecoration(
                labelText: 'Serviço Escolhido',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 235, 235, 235),
              ),
            ),
            const SizedBox(height: 20),
            // Outros campos do formulário
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Data do Evento',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Horário de Início',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Lógica para confirmar o agendamento
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }
}
