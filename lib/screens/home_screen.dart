import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // --- CABEÇALHO PERSONALIZADO ---
          Container(
            padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MUDANÇA AQUI: De FutureBuilder para StreamBuilder
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .snapshots(), // Usa snapshots() para ouvir em tempo real
                          builder: (context, snapshot) {
                            String displayName = user?.email?.split('@')[0] ?? 'Visitante';

                            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              if (data != null && data.containsKey('name')) {
                                displayName = data['name'];
                              }
                            }

                            return Text(
                              'Olá, $displayName!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'O que vamos celebrar hoje?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // --- BARRA DE PESQUISA ---
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Pesquisar serviços...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),

          // --- LISTA DE SERVIÇOS ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final services = snapshot.data!.docs;

                final filteredServices = services.where((serviceDoc) {
                  final serviceData = serviceDoc.data() as Map<String, dynamic>;
                  final serviceName = serviceData['name'].toString().toLowerCase();
                  return serviceName.contains(_searchText);
                }).toList();

                if (filteredServices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum serviço encontrado\npara "$_searchText"',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final serviceDoc = filteredServices[index];
                    final serviceData = serviceDoc.data() as Map<String, dynamic>;
                    final num displayPrice = serviceData['basePrice'] ?? serviceData['price'] ?? 0;
                    final bool hasVariations = serviceData.containsKey('basePrice');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
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
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                serviceData['imageUrl'] ?? 'https://placehold.co/600x400',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceData['name'] ?? 'Serviço sem nome',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    serviceData['description'] ?? 'Sem descrição.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hasVariations ? 'A partir de' : 'Preço fixo',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          Text(
                                            'R\$ ${displayPrice.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Ver Detalhes',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}