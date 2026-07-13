import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../core/widgets/fluttertoast.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Products product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int _quantity = 1;
  bool _isAddingToCart = false;
  bool _isBuyingNow = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart() async {
    final user = ref.read(authStateProvider).value;

    if (user == null) {
      SimpleToast.error('Please log in first');
      return;
    }

    setState(() => _isAddingToCart = true);

    await ref
        .read(CartServiceProvider)
        .addToCart(
          user.uid,
          widget.product.id.toString(),
          _quantity,
          widget.product.title ?? '',
          widget.product.thumbnail ?? '',
          widget.product.price ?? 0,
        );

    if (mounted) {
      setState(() => _isAddingToCart = false);
      SimpleToast.success('Added $_quantity item(s) to cart');
    }
  }

  Future<void> _handleBuyNow() async {
    final user = ref.read(authStateProvider).value;

    if (user == null) {
      SimpleToast.error('Please log in first');
      return;
    }

    setState(() => _isBuyingNow = true);

    await ref
        .read(CartServiceProvider)
        .addToCart(
          user.uid,
          widget.product.id.toString(),
          _quantity,
          widget.product.title ?? '',
          widget.product.thumbnail ?? '',
          widget.product.price ?? 0,
        );

    await ref.read(orderRepositoryProvider).placeOrder(user.uid);

    if (mounted) {
      setState(() => _isBuyingNow = false);
      SimpleToast.success('Order placed successfully!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final product = widget.product;
    final images = (product.images != null && product.images!.isNotEmpty)
        ? product.images!
        : [product.thumbnail ?? ''];

    final price = product.price ?? 0;
    final discount = product.discountPercentage ?? 0;
    final hasDiscount = discount > 0;
    final discountedPrice = hasDiscount
        ? price - (price * discount / 100)
        : price;

    final stock = product.stock ?? 0;
    final isOutOfStock = stock <= 0;
    final isLowStock = stock > 0 && stock <= 10;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 340,
            backgroundColor: surfaceColor,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  if (hasDiscount)
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.discountGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '-${discount.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  const SizedBox(height: 6),

                  Text(
                    product.title ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.rating,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        (product.rating ?? 0).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '  (${product.reviews?.length ?? 0} reviews)',
                        style: TextStyle(fontSize: 13, color: secondaryColor),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isOutOfStock
                                      ? AppColors.outOfStock
                                      : isLowStock
                                      ? AppColors.lowStock
                                      : AppColors.inStock)
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Out of Stock'
                              : isLowStock
                              ? 'Only $stock left'
                              : 'In Stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? AppColors.outOfStock
                                : isLowStock
                                ? AppColors.lowStock
                                : AppColors.inStock,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.priceTag,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: borderColor),
                  const SizedBox(height: 16),

                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: borderColor),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.local_shipping_outlined,
                    label: 'Shipping',
                    value: product.shippingInformation ?? 'Standard delivery',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Warranty',
                    value:
                        product.warrantyInformation ??
                        'No warranty information',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.assignment_return_outlined,
                    label: 'Return Policy',
                    value: product.returnPolicy ?? 'Not specified',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18, color: textColor),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18, color: textColor),
                    onPressed: (!isOutOfStock && _quantity < stock)
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: (isOutOfStock || _isAddingToCart || _isBuyingNow)
                    ? null
                    : _handleAddToCart,
                icon: _isAddingToCart
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                label: Text(
                  _isAddingToCart ? 'Adding...' : 'Add to Cart',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: (isOutOfStock || _isAddingToCart || _isBuyingNow)
                    ? null
                    : _handleBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? AppColors.outOfStock.withValues(alpha: 0.5)
                      : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isBuyingNow
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isOutOfStock ? 'Unavailable' : 'Buy Now',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 13, color: secondaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
