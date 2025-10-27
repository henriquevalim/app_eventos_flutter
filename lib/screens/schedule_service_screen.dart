import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// O ecrã de agendamento agora aceita uma variação opcional.
class ScheduleServiceScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final Map<String, dynamic>? selectedVariation;

  const ScheduleServiceScreen({
    super.key,
    required this.service,
    this.selectedVariation,
  });

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

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
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // A função de guardar foi atualizada para incluir os dados da variação.
  Future<void> _scheduleService() async {
    if (_selectedDate == null || _selectedTime == null || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha a data, hora e endereço do evento.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Determina o nome e o preço a serem guardados, com base na variação.
    final String finalServiceName = widget.service['name'];
    final num finalPrice = widget.selectedVariation?['price'] ?? widget.service['price'];
    final String? finalVariationDescription = widget.selectedVariation?['size'];

    try {
      await FirebaseFirestore.instance.collection('appointments').add({
        'userId': user.uid,
        'serviceId': widget.service['id'],
        'serviceName': finalServiceName,
        'servicePrice': finalPrice,
        // Novo campo para a descrição da variação.
        'serviceVariation': finalVariationDescription,
        'eventDate': Timestamp.fromDate(eventDateTime),
        'eventAddress': _addressController.text,
        'notes': _notesController.text,
        'status': 'Pendente',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento solicitado com sucesso!')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determina o nome do serviço a ser exibido no formulário.
    final String displayName = widget.selectedVariation != null
        ? '${widget.service['name']} (${widget.selectedVariation!['size']})'
        : widget.service['name'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Serviço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serviço Escolhido', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: TextEditingController(text: displayName),
              readOnly: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null ? 'Escolher Data' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null ? 'Escolher Hora' : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Endereço do Evento', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Rua Exemplo, 123, Bairro...'
              ),
            ),
            const SizedBox(height: 16),
            Text('Observações (Opcional)', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Alguma informação adicional?'
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _scheduleService,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white,)
                    : const Text('Confirmar Agendamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

