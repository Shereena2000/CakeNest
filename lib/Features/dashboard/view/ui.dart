import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../view_model.dart/dashboard_view_model.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Dashboard",
            actions: [
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () => dashboardVM.forceSync(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => dashboardVM.loadDashboardData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Overview", style: PTextStyles.labelMedium),
                    SizeBoxH(16),
                    
                    if (dashboardVM.isLoading)
                      Center(child: CircularProgressIndicator())
                    else
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildDashCard(
                            Icons.shopping_cart,
                            "Today's Sales",
                            dashboardVM.todaysSalesCount.toString(),
                          ),
                          _buildDashCard(
                            Icons.money_outlined,
                            "Today's Revenue",
                            "₹${dashboardVM.todaysSales.toStringAsFixed(2)}",
                          ),
                          _buildDashCard(
                            Icons.inventory,
                            "Total Inventory Value",
                            "₹${dashboardVM.totalInventoryValue.toStringAsFixed(2)}",
                          ),
                          _buildDashCard(
                            Icons.warning,
                            "Low Stock Items",
                            dashboardVM.lowStockItems.length.toString(),
                          ),
                        ],
                      ),
                    
                    SizeBoxH(24),
                    Text("Low Stock Items", style: PTextStyles.labelMedium),
                    SizeBoxH(12),
                    
                    if (dashboardVM.lowStockItems.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.green,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'All products are well stocked!',
                                style: PTextStyles.bodyMedium.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...dashboardVM.lowStockItems.map((product) => 
                        Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning,
                              color: product.stock == 0 ? Colors.red : Colors.orange,
                            ),
                            title: Text(product.name, style: PTextStyles.bodyMedium),
                            subtitle: Text(
                              "${product.category} • ₹${product.price.toStringAsFixed(2)}",
                              style: PTextStyles.bodySmall,
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: product.stock == 0 ? Colors.red : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${product.stock} left",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Card _buildDashCard(
    final IconData icon,
    final String heading,
    final String value,
  ) {
    return Card(
      color: PColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              heading,
              style: PTextStyles.labelMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: PTextStyles.labelSmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}