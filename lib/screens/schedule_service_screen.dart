import 'package:flutter/material.dart';

class ScheduleServiceScreen extends StatelessWidget {
  final String serviceTitle;

  const ScheduleServiceScreen({
    super.key,
    required this.serviceTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Serviço'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de Serviço Escolhido (não editável)
                    TextFormField(
                      initialValue: serviceTitle,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Serviço Escolhido',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Campo de Data
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Data do Evento',
                        hintText: 'DD/MM/AAAA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                    // Campo de Horário
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Horário de Início',
                        hintText: 'HH:MM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                    // Campo de Local
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Local do Evento',
                        hintText: 'Endereço completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botão de Confirmar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Logica para salvar o agendamento no Firestore
                  // Por enqt, apenas mostra um pop-up e volta
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Agendamento Enviado!'),
                      content: const Text('Seu pedido foi enviado. Entraremos em contato para confirmar.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Fecha o dialog
                            Navigator.of(context).pop(); // Volta da tela de agendamento
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar Agendamento',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
