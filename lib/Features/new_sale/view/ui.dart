
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_floating_action_button.dart';
import '../../sales/view_model/sale_view_model.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesViewModel>(context, listen: false).loadCustomersAndProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesViewModel>(
      builder: (context, salesVM, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "New Sale",
            actions: [
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: salesVM.currentSaleItems.isNotEmpty 
                    ? () => _showClearSaleDialog(context, salesVM)
                    : null,
              ),
            ],
          ),
          body: Column(
            children: [
              // Customer Selection Section
              Container(
                padding: EdgeInsets.all(16),
                color: PColors.primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.person, color: PColors.whiteColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: salesVM.selectedCustomer == null
                          ? GestureDetector(
                              onTap: () => _showCustomerSelection(context, salesVM),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: PColors.whiteColor.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Select Customer",
                                  style: PTextStyles.bodyMedium.copyWith(
                                    color: PColors.whiteColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _showCustomerSelection(context, salesVM),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: PColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: PColors.secondaryColor,
                                      radius: 16,
                                      child: Text(
                                        salesVM.selectedCustomer!.name[0].toUpperCase(),
                                        style: TextStyle(
                                          color: PColors.whiteColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            salesVM.selectedCustomer!.name,
                                            style: PTextStyles.bodyMedium,
                                          ),
                                          Text(
                                            salesVM.selectedCustomer!.phone,
                                            style: PTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.edit, size: 16, color: PColors.whiteColor),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              
              // Sale Items List
              Expanded(
                child: salesVM.currentSaleItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: PColors.whiteColor.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No items added yet",
                              style: PTextStyles.bodyMedium.copyWith(
                                color: PColors.whiteColor.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap + to add products",
                              style: PTextStyles.bodySmall.copyWith(
                                color: PColors.whiteColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: salesVM.currentSaleItems.length,
                        itemBuilder: (context, index) {
                          final item = salesVM.currentSaleItems[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.productName, style: PTextStyles.bodyMedium),
                              subtitle: Text(
                                "${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)}",
                                style: PTextStyles.bodySmall,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "₹${item.totalPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: PColors.whiteColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.delete_outlined, size: 16),
                                    onPressed: () => salesVM.removeItemFromSale(item.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: CustomFloatingActionButton(
            onPressed: () => _showProductSelection(context, salesVM),
          ),
          bottomNavigationBar: salesVM.currentSaleItems.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PColors.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total:",
                            style: PTextStyles.displayMedium,
                          ),
                          Text(
                            "₹${salesVM.currentSaleTotal.toStringAsFixed(2)}",
                            style: PTextStyles.displayMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (salesVM.selectedCustomer != null && 
                                     salesVM.currentSaleItems.isNotEmpty)
                              ? () => _completeSale(context, salesVM)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PColors.secondaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Complete Sale",
                            style: TextStyle(
                              color: PColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  void _showCustomerSelection(BuildContext context, SalesViewModel salesVM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Customer'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: salesVM.customers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 48),
                        SizedBox(height: 16),
                        Text('No customers found'),
                        SizedBox(height: 8),
                        Text('Add customers first', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: salesVM.customers.length,
                    itemBuilder: (context, index) {
                      final customer = salesVM.customers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: PColors.secondaryColor,
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: TextStyle(color: PColors.whiteColor),
                          ),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone),
                        onTap: () {
                          salesVM.selectCustomer(customer);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showProductSelection(BuildContext context, SalesViewModel salesVM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Product'),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: salesVM.products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48),
                        SizedBox(height: 16),
                        Text('No products found'),
                        SizedBox(height: 8),
                        Text('Add products first', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: salesVM.products.length,
                    itemBuilder: (context, index) {
                      final product = salesVM.products[index];
                      final isOutOfStock = product.stock <= 0;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isOutOfStock ? Colors.grey : PColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.cake,
                            color: PColors.whiteColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            color: isOutOfStock ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text(
                          'Stock: ${product.stock} - ₹${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isOutOfStock ? Colors.grey : null,
                          ),
                        ),
                        trailing: isOutOfStock
                            ? Text('Out of Stock', style: TextStyle(color: Colors.red))
                            : null,
                        enabled: !isOutOfStock,
                        onTap: isOutOfStock
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                _showQuantityDialog(context, product, salesVM);
                              },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showQuantityDialog(BuildContext context, product, SalesViewModel salesVM) {
    TextEditingController quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available: ${product.stock}'),
              SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0 && quantity <= product.stock) {
                  salesVM.addItemToSale(product, quantity);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid quantity'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showClearSaleDialog(BuildContext context, SalesViewModel salesVM) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Sale'),
          content: Text('Are you sure you want to clear all items from this sale?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                salesVM.clearCurrentSale();
                Navigator.of(context).pop();
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeSale(BuildContext context, SalesViewModel salesVM) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing sale...'),
            ],
          ),
        );
      },
    );

    try {
      final success = await salesVM.completeSale();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sale completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete sale'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}