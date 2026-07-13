import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/product_model.dart';
import '../services/product_service.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductsNotifier extends AsyncNotifier<List<Products>> {
  int _skip = 0;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  Future<List<Products>> build() async {
    _skip = 0;
    _hasMore = true;
    final repository = ref.read(productRepositoryProvider);
    final products = await repository.getAllProducts(
      limit: _limit,
      skip: _skip,
    );
    return products;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;
    final repository = ref.read(productRepositoryProvider);
    _skip += _limit;

    final newProducts = await repository.getAllProducts(
      limit: _limit,
      skip: _skip,
    );

    if (newProducts.isEmpty) {
      _hasMore = false;
      return;
    }

    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, ...newProducts]);
  }
}

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Products>>(
      ProductsNotifier.new,
    );
