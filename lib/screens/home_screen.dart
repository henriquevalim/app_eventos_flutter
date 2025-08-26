import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ServiceCard(
            icon: Icons.music_note,
            title: 'DJ Profissional',
            description: 'Música de alta qualidade para animar sua festa.',
            price: 'R\$ 800,00',
          ),
          SizedBox(height: 16),
          ServiceCard(
            icon: Icons.lightbulb_outline,
            title: 'Iluminação de Pista',
            description: 'Crie a atmosfera perfeita com luzes cênicas.',
            price: 'R\$ 650,00',
          ),
          SizedBox(height: 16),
          ServiceCard(
            icon: Icons.volume_up_outlined,
            title: 'Sistema de Som',
            description: 'Som cristalino para discursos e música ambiente.',
            price: 'R\$ 500,00',
          ),
        ],
      ),
    );
  }
}

// Widget reutilizável para os cards de serviço
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String price;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.indigo[50],
              child: Icon(icon, size: 28, color: Colors.indigo),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
