import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../core/widgets/fluttertoast.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPlacingOrder = false;

  Future<void> _confirmClearCart(String userId) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart?'),
        content: const Text('This will remove all items from your cart. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(CartServiceProvider).clearCart(userId);
      if (mounted) SimpleToast.success('Cart cleared');
    }
  }

  Future<void> _handlePlaceOrder(String userId) async {
    setState(() => _isPlacingOrder = true);

    await ref.read(orderRepositoryProvider).placeOrder(userId);

    if (mounted) {
      setState(() => _isPlacingOrder = false);
      SimpleToast.success('Order placed successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    var cartData = ref.watch(StreamcartProvider);
    var userId = ref.read(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
      ),
      body: cartData.when(
        data: (snapshot) {
          var docs = snapshot.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: secondaryColor),
                  const SizedBox(height: 14),
                  Text('Your cart is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                  const SizedBox(height: 6),
                  Text('Add products to see them here', style: TextStyle(fontSize: 13, color: secondaryColor)),
                ],
              ),
            );
          }

          double total = 0;
          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            total += (data['price'] ?? 0) * (data['quantity'] ?? 0);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    var productId = doc.id;
                    var quantity = data['quantity'] ?? 1;
                    var price = (data['price'] ?? 0).toDouble();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['thumbnail'] ?? '',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Container(
                                width: 64,
                                height: 64,
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                                child: const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.priceTag),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      isDark: isDark,
                                      onTap: () {
                                        ref.read(CartServiceProvider).updateQuantity(
                                          userId!,
                                          productId,
                                          quantity - 1,
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('$quantity', style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                                    ),
                                    _QtyButton(
                                      icon: Icons.add,
                                      isDark: isDark,
                                      onTap: () {
                                        ref.read(CartServiceProvider).updateQuantity(
                                          userId!,
                                          productId,
                                          quantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                onPressed: () {
                                  ref.read(CartServiceProvider).removeFromCart(userId!, productId);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8, bottom: 4),
                                child: Text(
                                  '\$${(price * quantity).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom summary: total + buttons
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.priceTag),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isPlacingOrder ? null : () => _confirmClearCart(userId!),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isPlacingOrder ? null : () => _handlePlaceOrder(userId!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isPlacingOrder
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _QtyButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
    );
  }
}