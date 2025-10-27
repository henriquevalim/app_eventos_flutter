
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatar datas

// Ecrã que exibe os agendamentos do utilizador, agora mostrando a variação.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("Faça login para ver os seus agendamentos."));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Os Meus Agendamentos'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximos'),
              Tab(text: 'Passados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentsList(
              FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: currentUser!.uid)
                  .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now())
                  .orderBy('eventDate', descending: false),
            ),
            _buildAppointmentsList(
              FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: currentUser!.uid)
                  .where('eventDate', isLessThan: Timestamp.now())
                  .orderBy('eventDate', descending: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(Query query) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Ocorreu um erro ao carregar os dados.'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nenhum agendamento encontrado.', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            DateTime eventDate = (data['eventDate'] as Timestamp).toDate();

            // Constrói a linha de subtítulo, incluindo a variação se ela existir.
            String subtitleText = '${DateFormat('EEEE, HH:mm', 'pt_BR').format(eventDate)}\nStatus: ${data['status']}';
            bool isThreeLine = false;
            if (data.containsKey('serviceVariation') && data['serviceVariation'] != null) {
              subtitleText += '\nOpção: ${data['serviceVariation']}';
              isThreeLine = true;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(DateFormat('d').format(eventDate)),
                ),
                title: Text(data['serviceName'] ?? 'Serviço'),
                subtitle: Text(subtitleText),
                isThreeLine: isThreeLine,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

