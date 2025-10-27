import 'package:eventos_app/screens/schedule_service_screen.dart';
import 'package:flutter/material.dart';

// Ecrã de detalhes agora é "Stateful" para gerir a seleção da variação.
class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  // Variável de estado para guardar a variação selecionada.
  Map<String, dynamic>? _selectedVariation;
  // Variável de estado para guardar o preço atual, que pode mudar.
  num? _currentPrice;

  @override
  void initState() {
    super.initState();
    // Ao iniciar o ecrã, definimos o preço inicial.
    // Se houver variações, usamos o `basePrice`. Se não, usamos o `price` fixo.
    if (widget.service.containsKey('variations')) {
      _currentPrice = widget.service['basePrice'];
    } else {
      _currentPrice = widget.service['price'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.service['items'] ?? [];
    final bool hasVariations = widget.service.containsKey('variations');
    final List<dynamic> variations = hasVariations ? widget.service['variations'] : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['name'] ?? 'Detalhes do Serviço'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.service['imageUrl'] ?? 'https://placehold.co/600x400/cccccc/ffffff?text=Imagem',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service['name'] ?? 'Nome indisponível',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // O texto do preço agora muda com base na seleção.
                  Text(
                    '${hasVariations && _selectedVariation == null ? 'A partir de ' : ''}R\$ ${_currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Se houver variações, mostra o menu de seleção (Dropdown).
                  if (hasVariations)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedVariation,
                      hint: const Text('Selecione uma opção'),
                      isExpanded: true,
                      // **CORREÇÃO APLICADA AQUI**
                      // Mapeamos a lista e garantimos que cada item é do tipo correto.
                      items: variations.map((variation) {
                        // Fazemos um "cast" para garantir ao Dart que este é um Map.
                        final variationMap = variation as Map<String, dynamic>;
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: variationMap,
                          child: Text('${variationMap['size']} - R\$ ${variationMap['price'].toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedVariation = newValue;
                          _currentPrice = newValue?['price'];
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Tamanho / Tipo',
                        border: OutlineInputBorder(),
                      ),
                    ),

                  const SizedBox(height: 16),
                  Text(
                    widget.service['description'] ?? 'Descrição não disponível.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'O que está incluso:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item.toString(), style: Theme.of(context).textTheme.bodyLarge)),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        // O botão fica desativado se for um serviço com variações e nenhuma tiver sido selecionada.
        child: ElevatedButton.icon(
          onPressed: (hasVariations && _selectedVariation == null) ? null : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleServiceScreen(
                  service: widget.service,
                  // Passamos a variação selecionada (se houver) para o ecrã de agendamento.
                  selectedVariation: _selectedVariation,
                ),
              ),
            );
          },
          icon: const Icon(Icons.calendar_month),
          label: const Text('Agendar este Serviço'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

