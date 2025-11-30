// Uma classe simples para representar um item no carrinho
class CartItem {
  final String serviceId;
  final String serviceName;
  final String variationSize;
  final num price;

  CartItem({
    required this.serviceId,
    required this.serviceName,
    required this.variationSize,
    required this.price,
  });
}

// Uma classe global para gerenciar a lista de itens
class CartManager {
  // A lista estática garante que os dados sejam acessíveis de qualquer tela
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(CartItem item) {
    _items.add(item);
  }

  static void removeItem(int index) {
    _items.removeAt(index);
  }

  static void clear() {
    _items.clear();
  }

  static double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.price);
  }

  static bool get isEmpty => _items.isEmpty;
}