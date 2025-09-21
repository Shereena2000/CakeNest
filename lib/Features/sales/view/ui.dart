import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../view_model/sale_view_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesViewModel>(context, listen: false).loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesViewModel>(
      builder: (context, salesVM, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Sales History",
            actions: [
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () => salesVM.forceSync(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => salesVM.loadSales(),
            child: salesVM.isLoading
                ? Center(child: CircularProgressIndicator())
                : salesVM.sales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: PColors.whiteColor.withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No sales yet',
                              style: PTextStyles.bodyMedium.copyWith(
                                color: PColors.whiteColor.withOpacity(0.7),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Your sales will appear here',
                                style: PTextStyles.bodySmall.copyWith(
                                  color: PColors.whiteColor.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: salesVM.sales.length,
                        itemBuilder: (context, index) {
                          final sale = salesVM.sales[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: sale.synced ? Colors.green : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.receipt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                sale.customerName,
                                style: PTextStyles.bodyMedium,
                              ),
                              subtitle: Text(
                                "${DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate)}",
                                style: PTextStyles.bodySmall,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "₹${sale.totalAmount.toStringAsFixed(2)}",
                                    style: PTextStyles.labelMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!sale.synced)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Syncing...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => _showSaleDetails(context, sale, salesVM),
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }

  void _showSaleDetails(BuildContext context, sale, SalesViewModel salesVM) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading sale details...'),
            ],
          ),
        );
      },
    );

    try {
      final saleItems = await salesVM.getSaleDetails(sale.id);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show sale details dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: PColors.whiteColor,
            title: Text(
              'Sale Details',
              style: PTextStyles.displaySmall.copyWith(color: PColors.blackColor),
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale Info
                  _buildDetailRow('Sale ID:', sale.id.substring(0, 8)),
                  _buildDetailRow('Customer:', sale.customerName),
                  _buildDetailRow('Date:', DateFormat('dd/MM/yyyy').format(sale.saleDate)),
                  _buildDetailRow('Time:', DateFormat('HH:mm').format(sale.saleDate)),
                  
                  SizeBoxH(16),
                  Text(
                    'Items:',
                    style: PTextStyles.bodyMedium.copyWith(color: PColors.blackColor),
                  ),
                  SizeBoxH(8),
                  
                  // Items List
                  Container(
                    height: 200,
                    child: saleItems.isEmpty
                        ? Center(child: Text('No items found'))
                        : ListView.builder(
                            itemCount: saleItems.length,
                            itemBuilder: (context, index) {
                              final item = saleItems[index];
                              return ListTile(
                                title: Text(
                                  item.productName,
                                  style: PTextStyles.bodyMedium.copyWith(
                                    color: PColors.blackColor,
                                  ),
                                ),
                                subtitle: Text(
                                  '${item.quantity} x ₹${item.unitPrice.toStringAsFixed(2)}',
                                  style: PTextStyles.bodySmall.copyWith(
                                    color: PColors.blackColor,
                                  ),
                                ),
                                trailing: Text(
                                  '₹${item.totalPrice.toStringAsFixed(2)}',
                                  style: PTextStyles.bodyMedium.copyWith(
                                    color: PColors.blackColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  Divider(color: PColors.blackColor),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: PTextStyles.labelMedium.copyWith(
                          color: PColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${sale.totalAmount.toStringAsFixed(2)}',
                        style: PTextStyles.labelMedium.copyWith(
                          color: PColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: PColors.primaryColor),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load sale details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: PTextStyles.bodyMedium.copyWith(
              color: PColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: PTextStyles.bodySmall.copyWith(color: PColors.blackColor),
            ),
          ),
        ],
      ),
    );
  }
}