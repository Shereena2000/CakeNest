import 'package:cake_nest/Features/common_widgets/custom_floating_action_button.dart';
import 'package:flutter/material.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../model/product_model.dart';
import 'widgets/product_card.dart';
import 'widgets/product_dialog.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Products"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.69,
          children: [
            ProductCard(
              imagePath: "assets/images/cake.jpg",
              productName: "Chocolate Cake",
              category: "Cake",
              stock: 10,
              price: 25.0,
              onEdit: () {
                print("Edit tapped");
              },
              onDelete: () {
                print("Delete tapped");
              },
            ),

            ProductCard(
              imagePath: "assets/images/coockie.jpeg",
              productName: "Chocolate coockie",
              category: "Coockie",
              stock: 10,
              price: 25.0,
              onEdit: () {
                print("Edit tapped");
              },
              onDelete: () {
                print("Delete tapped");
              },
            ),

            ProductCard(
              imagePath: "assets/images/cupCakes.jpeg",
              productName: "Vanilla Cupcakes",
              category: "Cupcakes",
              stock: 10,
              price: 25.0,
              onEdit: () {
                print("Edit tapped");
              },
              onDelete: () {
                print("Delete tapped");
              },
            ),
            ProductCard(
              imagePath: "assets/images/tart.jpeg",
              productName: "Strawberry Tart",
              category: "Tart",
              stock: 10,
              price: 25.0,
              onEdit: () {
                print("Edit tapped");
              },
              onDelete: () {
                print("Delete tapped");
              },
            ),
            ProductCard(
              imagePath: "assets/images/muffin.jpeg",
              productName: "Blueberry Muffin",
              category: "Muffin",
              stock: 10,
              price: 25.0,
              onEdit: () {
                print("Edit tapped");
              },
              onDelete: () {
                print("Delete tapped");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          _showProductDialog(context);
        },
      ),
    );
  }
}

void _showProductDialog(BuildContext context, {Product? product, int? index}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ProductDialog(product: product, onSave: (newProduct) {});
    },
  );
}
