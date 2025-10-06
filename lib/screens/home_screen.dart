import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventos_app/screens/service_detail_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta as mudanças na coleção 'services' em tempo real
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          // Enquanto os dados estão carregando, mostra um indicador de progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se ocorrer um erro
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar os serviços.'));
          }

          // Se não houver dados
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum serviço encontrado.'));
          }

          // Se os dados foram carregados com sucesso
          final services = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              // Converte os dados do documento para um mapa
              final serviceData = service.data() as Map<String, dynamic>;

              return ServiceCard(serviceData: serviceData);
            },
          );
        },
      ),
    );
  }
}

// O Widget ServiceCard permanece o mesmo, mas agora recebe os dados
class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceCard({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: serviceData),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                serviceData['imageUrl'] ?? 'https://placehold.co/600x400/cccccc/ffffff?text=Imagem',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                // Adiciona um loading builder para uma melhor experiência
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 180,
                    child: Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceData['name'] ?? 'Serviço sem nome',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A partir de R\$ ${serviceData['price'] ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

