import 'package:eventos_app/screens/schedule_service_screen.dart';
import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  // Ele espera receber um Map<String, dynamic> com o nome 'service'.
  final Map<String, dynamic> service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    // Pega a lista de 'items' do mapa, tratando o caso de ser nula
    final List<dynamic> items = service['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(service['name'] ?? 'Detalhes do Serviço'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              service['imageUrl'] ?? 'https://placehold.co/600x400',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['name'] ?? 'Serviço sem nome',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A partir de R\$ ${service['price'] ?? 0}',
                    style: TextStyle(fontSize: 20, color: Colors.grey[800], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    service['description'] ?? 'Sem descrição disponível.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'O que está incluso:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Mapeia a lista de items para criar os ListTile
                  ...items.map((item) => ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: Colors.indigo),
                    title: Text(item.toString()),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleServiceScreen(serviceName: service['name'] ?? ''),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('Agendar este Serviço'),
        ),
      ),
    );
  }
}
