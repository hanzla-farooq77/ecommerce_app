import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';

final CartServiceProvider = Provider((ref) {
  return CartRepository();
});

final StreamcartProvider = StreamProvider((ref) {
  var repository = ref.watch(CartServiceProvider);
  var user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }
  var userId = user.uid;
  return repository.watchCart(userId);
});
