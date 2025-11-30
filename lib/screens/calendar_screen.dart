import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pacote para formatar datas
import 'package:url_launcher/url_launcher.dart'; // Para o WhatsApp

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // **** NOVA FUNÇÃO ****
  // Função para notificar o admin sobre um CANCELAMENTO
  Future<void> _launchWhatsAppCancellation(Map<String, dynamic> appointmentData) async {
    // --- IMPORTANTE O NUMERO AQUI ---
    const adminPhoneNumber = '5551920005515';

    final String serviceName = appointmentData['serviceName'] ?? 'Serviço';
    final String variationSize = appointmentData['variationSize'] ?? '';
    final DateTime eventDate = (appointmentData['eventDate'] as Timestamp).toDate();
    final String formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(eventDate);
    final String userEmail = currentUser?.email ?? 'Email não disponível';
    // ADICIONADO: Capturar o endereço para a notificação
    final String address = appointmentData['address'] ?? 'Endereço não informado';

    final String message = """
*!! CANCELAMENTO DE AGENDAMENTO !! (EvenTech App)*

O seguinte pedido de agendamento foi CANCELADO pelo cliente:

*Serviço:* $serviceName
*Opção:* $variationSize
*Data:* $formattedDate
*Endereço:* $address
*Cliente:* $userEmail
""";

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$adminPhoneNumber?text=$encodedMessage'
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Não foi possível abrir o WhatsApp para notificar o cancelamento.");
      // Mesmo que não abra o WhatsApp, o cancelamento continua
    }
  }

  // Função para mostrar o diálogo de confirmação
  void _showCancelConfirmationDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: const Text('Tem a certeza de que deseja cancelar este agendamento? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sim, Cancelar'),
              onPressed: () async {
                Navigator.of(ctx).pop(); // Fecha o diálogo

                try {
                  // 1. Tenta notificar o admin no WhatsApp
                  await _launchWhatsAppCancellation(data);

                  // 2. Apaga o documento do Firestore
                  await doc.reference.delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agendamento cancelado com sucesso.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao cancelar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

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
            String status = data['status'] ?? 'Pendente';
            bool isPendente = status == 'Pendente';

            String subtitleText = '${DateFormat('EEEE, HH:mm', 'pt_BR').format(eventDate)}\nStatus: $status';
            bool isThreeLine = false;
            if (data.containsKey('variationSize') && data['variationSize'] != 'Serviço Padrão') {
              subtitleText += '\nOpção: ${data['variationSize']}';
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
                // **** BOTÃO DE CANCELAR ****
                // Só aparece se o status for "Pendente"
                trailing: isPendente
                    ? IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  tooltip: 'Cancelar Agendamento',
                  onPressed: () {
                    // Chama o diálogo de confirmação
                    _showCancelConfirmationDialog(doc);
                  },
                )
                    : null, // Não mostra nada se não estiver pendente
              ),
            );
          }).toList(),
        );
      },
    );
  }
}