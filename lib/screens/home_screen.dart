import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventos_app/screens/service_detail_screen.dart';
import 'package:flutter/material.dart';

// A tela Home agora mostra "A partir de" para serviços com variações.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nossos Serviços'),
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),
      // Usa um StreamBuilder para ouvir as atualizações da coleção 'services' em tempo real.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          // Enquanto os dados estão a carregar, mostra um indicador de progresso.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se ocorrer um erro, mostra uma mensagem de erro.
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar os serviços.'));
          }
          // Se não houver dados, mostra uma mensagem.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum serviço disponível no momento.'));
          }

          // Se houver dados, constrói a lista de serviços.
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              // Converte o documento do Firestore para um mapa de dados.
              Map<String, dynamic> serviceData = doc.data()! as Map<String, dynamic>;

              // LÓGICA ATUALIZADA PARA O PREÇO
              final bool hasVariations = serviceData.containsKey('variations');
              final price = hasVariations ? serviceData['basePrice'] : serviceData['price'];
              final priceText = hasVariations ? 'A partir de R\$ ${price?.toStringAsFixed(2)}' : 'R\$ ${price?.toStringAsFixed(2)}';


              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    // Navega para a tela de detalhes, passando os dados do serviço clicado.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailScreen(service: serviceData),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagem do serviço
                      Image.network(
                        serviceData['imageUrl'] ?? 'https://placehold.co/600x400/cccccc/ffffff?text=Imagem',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Nome e preço do serviço
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceData['name'] ?? 'Serviço sem nome',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priceText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

