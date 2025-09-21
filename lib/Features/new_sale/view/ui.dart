import 'package:cake_nest/Features/common_widgets/custom_app_bar.dart';
import 'package:cake_nest/Settings/constants/sized_box.dart';
import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';

import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_floating_action_button.dart';

class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "New Sale"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("We need to add search customer"),
            ListTile(
              title: Text("Chocolate Cake", style: PTextStyles.bodyMedium),
              subtitle: Text("3 x 25.00", style: PTextStyles.bodySmall),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("\$75", style: TextStyle(color: PColors.whiteColor,fontSize: 16)),
                  SizeBoxV(8),
                  Icon(Icons.delete_outlined, size: 16, color: PColors.whiteColor),
                ],
              ),
            ),
          ],
        ),
      ),
       floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
    //     _showProductSelection(context);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(color: PColors.whiteColor, thickness: 0.5),
              Text("Total : \$75.00", style: PTextStyles.displayMedium),
            ],
          ),
        ),
      ),
    );
  }
  // void _showQuantityDialog(Product product) {
  //   TextEditingController quantityController = TextEditingController(text: '1');

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Add ${product.name}'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('Available: ${product.stock}'),
  //             SizedBox(height: 10),
  //             TextFormField(
  //               controller: quantityController,
  //               decoration: InputDecoration(labelText: 'Quantity'),
  //               keyboardType: TextInputType.number,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // int quantity = int.tryParse(quantityController.text) ?? 0;
  //               // if (quantity > 0 && quantity <= product.stock) {
  //               //   _addItem(product, quantity);
  //               //   Navigator.of(context).pop();
  //               // }
  //             },
  //             child: Text('Add'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //   void _showProductSelection(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Select Product'),
  //         content: Container(
  //           width: double.maxFinite,
  //           height: 300,
  //           child: ListView.builder(
  //             itemCount: widget.products.length,
  //             itemBuilder: (context, index) {
  //               Product product = widget.products[index];
  //               return ListTile(
  //                 title: Text(product.name),
  //                 subtitle: Text(
  //                   'Stock: ${product.stock} - \$${product.price.toStringAsFixed(2)}',
  //                 ),
  //                 enabled: product.stock > 0,
  //                 onTap: product.stock > 0
  //                     ? () {
  //                         Navigator.of(context).pop();
  //                         _showQuantityDialog(product);
  //                       }
  //                     : null,
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
