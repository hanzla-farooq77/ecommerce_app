import 'package:cloud_firestore/cloud_firestore.dart';

class CartRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getCartFolder(String userId) {
    return firestore.collection('users').doc(userId).collection('cart');
  }

  addToCart(String userId, String productId, int quantity, String title, String thumbnail, double price) async {
    var productBox = getCartFolder(userId).doc(productId);
    var existingBox = await productBox.get();

    if (existingBox.exists) {
      var oldQuantity = existingBox['quantity'];
      await productBox.update({'quantity': oldQuantity + quantity});
    } else {
      await productBox.set({
        'quantity': quantity,
        'title': title,
        'thumbnail': thumbnail,
        'price': price,
      });
    }
  }

  watchCart(String userId) {
    return getCartFolder(userId).snapshots();
  }

  updateQuantity(String userId, String productId, int newQuantity) async {
    var productBox = getCartFolder(userId).doc(productId);
    if (newQuantity <= 0) {
      await productBox.delete();
    } else {
      await productBox.update({'quantity': newQuantity});
    }
  }

  removeFromCart(String userId, String productId) async {
    var productBox = getCartFolder(userId).doc(productId);
    await productBox.delete();
  }

  clearCart(String userId) async {
    var cartFolder = getCartFolder(userId);
    var allItems = await cartFolder.get();
    for (var doc in allItems.docs) {
      await doc.reference.delete();
    }
  }

}
