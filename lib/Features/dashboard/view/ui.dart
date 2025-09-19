import 'package:cake_nest/Settings/constants/sized_box.dart';
import 'package:cake_nest/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../common_widgets/custom_app_bar.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const CustomAppBar(title: "Dashboard"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today\'s Overview", style: PTextStyles.labelMedium),
              SizeBoxH(5),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDashCard(Icons.shopping_cart, "Today\'s Sales", "120"),
                  _buildDashCard(
                    Icons.money_outlined,
                    "Today\'s Revenue",
                    "85",
                  ),
                  _buildDashCard(
                    Icons.inventory,
                    "Total Inventory Value",
                    "65",
                  ),
                  _buildDashCard(Icons.warning, "Low Stock Items", "40"),
                ],
              ),
              SizeBoxH(12),

              Text("Low Stock Items", style: PTextStyles.labelMedium),

              ListTile(
                leading: Icon(Icons.cake, color: PColors.whiteColor),
                title: Text("Vanila Cup Cakes", style: PTextStyles.bodyMedium),
                subtitle: Text("Only 0 left", style: PTextStyles.bodySmall),
              ),
            ],
          ),
        ),
      ),
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
            ),
            const SizedBox(height: 6),
            Text(value, style: PTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}
