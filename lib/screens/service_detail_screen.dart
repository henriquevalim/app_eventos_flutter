import 'package:eventos_app/models/cart_model.dart';
import 'package:eventos_app/screens/schedule_service_screen.dart';
import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  Map<String, dynamic>? _selectedVariation;
  num? _currentPrice;

  @override
  void initState() {
    super.initState();
    if (widget.service.containsKey('variations')) {
      _currentPrice = widget.service['basePrice'];
    } else {
      _currentPrice = widget.service['price'];
    }
  }

  void _addToCartAndDecide() {
    final item = CartItem(
      serviceId: widget.service['id'] ?? 'unknown',
      serviceName: widget.service['name'],
      variationSize: _selectedVariation != null
          ? _selectedVariation!['size']
          : 'Serviço Padrão',
      price: _currentPrice ?? 0,
    );

    CartManager.addItem(item);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Item Adicionado!'),
        content: const Text('Gostaria de adicionar mais serviços ao seu pedido ou finalizar agora?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Adicionar Mais'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleServiceScreen()),
              );
            },
            child: const Text('Finalizar Pedido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = widget.service['items'] ?? [];
    final bool hasVariations = widget.service.containsKey('variations');
    final List<dynamic> variations = hasVariations ? widget.service['variations'] : [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.service['name'] ?? 'Detalhes')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.service['imageUrl'] ?? 'https://placehold.co/600x400',
              width: double.infinity, height: 250, fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.service['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${hasVariations && _selectedVariation == null ? 'A partir de ' : ''}R\$ ${_currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 16),
                  if (hasVariations)
                    DropdownButtonFormField<Map<String, dynamic>>(
                      value: _selectedVariation,
                      hint: const Text('Selecione uma opção'),
                      isExpanded: true,
                      items: variations.map((variation) {
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
                      decoration: const InputDecoration(labelText: 'Tamanho / Tipo', border: OutlineInputBorder()),
                    ),
                  const SizedBox(height: 16),
                  Text(widget.service['description'] ?? '', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text('O que está incluso:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...items.map((item) => ListTile(
                    leading: const Icon(Icons.check, size: 20),
                    title: Text(item.toString()),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      // MUDANÇA AQUI: Adicionado SafeArea para evitar sobreposição
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: (hasVariations && _selectedVariation == null) ? null : _addToCartAndDecide,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Adicionar ao Pedido'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}