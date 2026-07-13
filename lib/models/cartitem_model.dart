class CartItem {
  final String productId;
  final String title;
  final String thumbnail;
  final double price;
  final double discountPercentage;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.discountPercentage,
    required this.quantity,
  });

  double get discountedPrice => price - (price * discountPercentage / 100);
  double get subtotal => discountedPrice * quantity;

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      productId: id,
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPercentage: (map['discountPercentage'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'discountPercentage': discountPercentage,
      'quantity': quantity,
    };
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      title: title,
      thumbnail: thumbnail,
      price: price,
      discountPercentage: discountPercentage,
      quantity: quantity ?? this.quantity,
    );
  }
}