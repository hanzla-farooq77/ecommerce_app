import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/order_service.dart';

final orderRepositoryProvider = Provider((ref) {
  return OrderService();
});