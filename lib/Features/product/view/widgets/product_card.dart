import 'package:flutter/material.dart';
import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:cake_nest/Settings/utils/p_text_styles.dart';
import 'package:provider/provider.dart';

import '../../model/product_model.dart';
import '../../view_model/view_model.dart';
import 'product_dialog.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String productName;
  final String category;
  final int stock;
  final double price;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,

    required this.productName,
    required this.category,
    required this.stock,
    required this.price,
    this.onEdit,
    this.onDelete,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> categoryImages = {
      'Cake': 'assets/images/cake.jpg',
      'Cupcake': 'assets/images/cupCakes.jpeg',
      'Muffin': 'assets/images/muffin.jpeg',
      'Tart': 'assets/images/tart.jpeg',
      'Cookie': 'assets/images/coockie.jpeg',
    };

    final String image =
        categoryImages[category] ?? 'assets/images/default.jpeg';

    return Consumer<ProductViewModel>(
      builder: (context, productVM, child) {
        return Card(
          shadowColor: PColors.secondaryColor,
          elevation: 5,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          color: PColors.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: PTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "$category : Stock $stock",
                        style: PTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: product.synced
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),

                              PopupMenuButton<String>(
                                onSelected: (value) => _handleMenuAction(
                                  context,
                                  value,
                                  product,
                                  productVM,
                                ),
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 16),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    product,
    ProductViewModel productVM,
  ) {
    switch (action) {
      case 'edit':
        _showProductDialog(context, product: product);
        break;
      case 'delete':
        _showDeleteConfirmation(context, product, productVM);
        break;
    }
  }

  void _showProductDialog(BuildContext context, {product}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProductDialog(product: product);
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    product,
    ProductViewModel productVM,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete ${product.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await productVM.deleteProduct(product.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete product'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
