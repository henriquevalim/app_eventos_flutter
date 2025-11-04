import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatar a data
import 'package:url_launcher/url_launcher.dart'; // Pacote para abrir o WhatsApp

class ScheduleServiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  // ATUALIZAÇÃO: Tornámos a variação opcional (nullable) para corrigir o erro
  final Map<String, dynamic>? selectedVariation;

  const ScheduleServiceScreen({
    super.key,
    required this.service,
    this.selectedVariation, // ATUALIZAÇÃO: Agora é opcional
  });

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

  // Função para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Função para selecionar a hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  // Função principal de agendamento
  Future<void> _scheduleService() async {
    if (!_formKey.currentState!.validate()) {
      return; // Se o formulário for inválido, não faz nada
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Utilizador não autenticado.");
      }

      // Combina a data e a hora selecionadas
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // ATUALIZAÇÃO: Verifica se há uma variação ou se é um preço base
      // Esta lógica agora lida com 'selectedVariation' sendo nulo
      final bool hasVariation = widget.selectedVariation != null && widget.selectedVariation!.isNotEmpty;
      final String variationSize = hasVariation ? widget.selectedVariation!['size'] : 'Serviço Padrão';
      // 'price' ou 'basePrice'
      final num priceFromService = widget.service['price'] ?? widget.service['basePrice'] ?? 0;
      final num variationPrice = hasVariation ? widget.selectedVariation!['price'] : priceFromService;


      // 1. Salva o agendamento no Firestore
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'serviceId': widget.service['id'],
        'serviceName': widget.service['name'],
        'variationSize': variationSize,
        'variationPrice': variationPrice,
        'eventDate': Timestamp.fromDate(eventDateTime),
        'address': _address,
        'status': 'Pendente',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Prepara a mensagem para o WhatsApp
      final String formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(eventDateTime);
      final String finalMessage = """
*Novo Pedido de Agendamento (EvenTech App)*

Um novo pedido de agendamento foi realizado:

*Serviço:* ${widget.service['name']}
*Opção:* $variationSize
*Preço:* R\$ $variationPrice
*Data:* $formattedDate
*Endereço:* $_address

*Cliente:* ${user.email ?? 'Email não disponível'}
""";

      // 3. Tenta abrir o WhatsApp com a mensagem
      await _launchWhatsApp(finalMessage);

      // Mostra o sucesso para o cliente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento solicitado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao agendar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Função para formatar a mensagem e abrir o WhatsApp
  Future<void> _launchWhatsApp(String message) async {

    const adminPhoneNumber = '5551920005515'; //

    // Codifica a mensagem para ser segura num URL
    final String encodedMessage = Uri.encodeComponent(message);

    // Cria o link do WhatsApp
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$adminPhoneNumber?text=$encodedMessage'
    );

    // Tenta abrir o link
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // Se não conseguir abrir
      debugPrint("Não foi possível abrir o WhatsApp.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento salvo, mas não foi possível notificar via WhatsApp.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Lógica para lidar com variação nula
    String serviceName = widget.service['name'] ?? 'Serviço';
    final bool hasVariation = widget.selectedVariation != null && widget.selectedVariation!.isNotEmpty;
    final String variationName = hasVariation ? widget.selectedVariation!['size'] : 'Serviço Padrão';
    // 'price' ou 'basePrice'
    final num priceFromService = widget.service['price'] ?? widget.service['basePrice'] ?? 0.0;
    final double variationPrice = (hasVariation ? widget.selectedVariation!['price'] : priceFromService).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Serviço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              //  Só mostra a opção se ela existir (e não for "Serviço Padrão")
              if (hasVariation && variationName != 'Serviço Padrão')
                Text(
                  'Opção: $variationName',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              if (hasVariation && variationName != 'Serviço Padrão') const SizedBox(height: 8),
              Text(
                'Preço: R\$ ${variationPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Divider(height: 32),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data do Evento',
                  hintText: 'Selecione a data',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Por favor, selecione uma data.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Hora de Início',
                  hintText: 'Selecione a hora',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (value) {
                  if (_selectedTime == null) {
                    return 'Por favor, selecione uma hora.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Endereço do Evento',
                  hintText: 'Ex: Rua, Número, Bairro, Cidade',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _address = value;
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o endereço.';
                  }
                  return null;
                },
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
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text('Confirmar Agendamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

