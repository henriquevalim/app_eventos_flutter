import 'package:eventos_app/models/cart_model.dart'; // Importe o carrinho
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleServiceScreen extends StatefulWidget {
  const ScheduleServiceScreen({super.key});

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _address = '';
  bool _isLoading = false;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _scheduleService() async {
    if (!_formKey.currentState!.validate()) return;
    if (CartManager.items.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Utilizador não autenticado.");

      final eventDateTime = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      // --- CRIA A LISTA DE ITENS PARA SALVAR ---
      final List<Map<String, dynamic>> itemsToSave = CartManager.items.map((item) {
        return {
          'serviceId': item.serviceId,
          'serviceName': item.serviceName,
          'variationSize': item.variationSize,
          'price': item.price,
        };
      }).toList();

      // --- SALVA NO FIRESTORE ---
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'items': itemsToSave, // Array com todos os itens
        'totalPrice': CartManager.totalAmount,
        'eventDate': Timestamp.fromDate(eventDateTime),
        'address': _address,
        'status': 'Pendente',
        'createdAt': FieldValue.serverTimestamp(),
        // Campos legados para compatibilidade com o Calendar antigo (pega o 1º item)
        'serviceName': '${CartManager.items.length} itens (Ver Detalhes)',
        'variationSize': 'Pacote Personalizado',
      });

      // --- FORMATA A MENSAGEM DO WHATSAPP ---
      String itemsListString = "";
      for (var item in CartManager.items) {
        itemsListString += "- ${item.serviceName} (${item.variationSize}): R\$ ${item.price.toStringAsFixed(2)}\n";
      }

      final String finalMessage = """
*Novo Pedido de Agendamento (EvenTech App)*

*Cliente:* ${user.email}
*Data:* ${_dateController.text} às ${_timeController.text}
*Endereço:* $_address

*Itens do Pedido:*
$itemsListString
*TOTAL: R\$ ${CartManager.totalAmount.toStringAsFixed(2)}*
""";

      await _launchWhatsApp(finalMessage);

      // --- LIMPA O CARRINHO E VOLTA ---
      CartManager.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido realizado com sucesso!'), backgroundColor: Colors.green));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchWhatsApp(String message) async {
    const adminPhoneNumber = '5551920005515'; // SEU NÚMERO
    final Uri whatsappUri = Uri.parse('https://wa.me/$adminPhoneNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("WhatsApp não instalado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pedido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- LISTA DE ITENS DO CARRINHO ---
              const Text('Resumo do Pedido:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true, // Importante para estar dentro de Column
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: CartManager.items.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = CartManager.items[i];
                    return ListTile(
                      title: Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item.variationSize),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('R\$ ${item.price.toStringAsFixed(2)}'),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              setState(() {
                                CartManager.removeItem(i);
                                if (CartManager.isEmpty) Navigator.pop(context); // Sai se esvaziar
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: R\$ ${CartManager.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
              ),
              const Divider(height: 32),

              // --- FORMULÁRIO DE DADOS ---
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Data do Evento', prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (v) => v!.isEmpty ? 'Selecione a data' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Hora', prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (v) => v!.isEmpty ? 'Selecione a hora' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Endereço', prefixIcon: Icon(Icons.location_on), border: OutlineInputBorder()),
                onChanged: (v) => _address = v,
                validator: (v) => v!.isEmpty ? 'Informe o endereço' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _scheduleService,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirmar Pedido Completo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}