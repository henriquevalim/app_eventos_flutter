import 'package:flutter/material.dart';
import 'service_detail_screen.dart'; // Importa a nova tela

// Classe para modelar os dados de um serviço
class Service {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final List<String> includedItems;

  const Service({
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.includedItems,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Lista de serviços (mock data)
  final List<Service> services = const [
    Service(
      title: 'DJ Profissional',
      description: 'Música de alta qualidade para animar sua festa, com repertório personalizado.',
      price: 'R\$ 800,00',
      icon: Icons.music_note,
      includedItems: [
        '4 horas de performance',
        'Equipamento de DJ completo',
        'Reunião de alinhamento musical',
      ],
    ),
    Service(
      title: 'Iluminação de Pista',
      description: 'Crie a atmosfera perfeita com luzes cênicas e de dança profissionais.',
      price: 'R\$ 650,00',
      icon: Icons.lightbulb_outline,
      includedItems: [
        'Canhões de LED',
        'Moving Heads',
        'Máquina de fumaça',
        'Montagem e operação',
      ],
    ),
    Service(
      title: 'Sistema de Som',
      description: 'Som cristalino para discursos, música ambiente e pequenas apresentações.',
      price: 'R\$ 500,00',
      icon: Icons.volume_up_outlined,
      includedItems: [
        '2 Caixas de som ativas',
        'Mesa de som',
        '1 Microfone com fio',
        'Técnico de som',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ServiceCard(
              icon: service.icon,
              title: service.title,
              description: service.description,
              price: service.price,
              onTap: () {
                // Ação de clique: navegar para a tela de detalhes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailScreen(
                      title: service.title,
                      price: service.price,
                      description: service.description,
                      icon: service.icon,
                      includedItems: service.includedItems,
                    ),
                  ),
                );
              },
            ),
          );
        },
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
  final VoidCallback onTap; // Função a ser chamada no clique

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // Executa a função onTap ao ser clicado
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
                    Text(
                      description,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
