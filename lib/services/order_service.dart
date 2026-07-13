import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  OrderedData(String userId) async {
    return firestore.collection("users").doc(userId).collection("Orders");
  }

  placeOrder(String userId) async {
    var cartSnapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    List<Map<String, dynamic>> orderItems = [];
    double totalAmount = 0;

    for (var doc in cartSnapshot.docs) {
      var data = doc.data();
      orderItems.add(data);
      totalAmount += (data['price'] ?? 0) * (data['quantity'] ?? 0);
    }

    await OrderedData(userId).add({
      'items': orderItems,
      'totalAmount': totalAmount,
      'orderDate': DateTime.now().toIso8601String(),
      'status': 'pending',
    });

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
