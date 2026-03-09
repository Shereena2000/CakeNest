import 'package:cake_nest/Features/product/view/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_floating_action_button.dart';
import '../view_model/view_model.dart';
import 'widgets/product_dialog.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductViewModel>(context, listen: false).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, productVM, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Products",
            actions: [
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () => productVM.forceSync(),
              ),
            ],
          ),
          body: productVM.isLoading
              ? Center(child: CircularProgressIndicator())
              : productVM.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: PColors.whiteColor.withOpacity(0.5),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No products yet',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: PColors.whiteColor.withOpacity(0.7),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Add your first product',
                          style: PTextStyles.bodySmall.copyWith(
                            color: PColors.whiteColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => productVM.loadProducts(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: productVM.products.length,
                      itemBuilder: (context, index) {
                        final product = productVM.products[index];
                        return ProductCard(
                          productName: product.name,
                          category: product.category,
                          stock: product.stock,
                          price: product.price,
                          product: product,
                        );
                      },
                    ),
                  ),
                ),
          floatingActionButton: CustomFloatingActionButton(
            onPressed: () => _showProductDialog(context),
          ),
        );
      },
    );
  }

  void _showProductDialog(BuildContext context, {product}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ProductDialog(product: product);
      },
    );
  }
}
