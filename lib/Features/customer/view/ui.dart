import 'package:cake_nest/Features/common_widgets/custom_app_bar.dart';
import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:cake_nest/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/custom_floating_action_button.dart' show CustomFloatingActionButton;
import '../model/customer_model.dart';
import 'widgets/customer_dialog.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers"),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: PColors.secondaryColor,
                child: Text("a", style: TextStyle(color: PColors.whiteColor)),
              ),
              title: Text("Ebin", style: PTextStyles.bodyMedium),
              subtitle: Text("7592946170", style: PTextStyles.bodySmall),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {},
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ],
        ),
      ),
       floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
         _showCustomerDialog(context);
        },
      ),
    );
  }

   void _showCustomerDialog(
    BuildContext context, {
    Customer? customer,
    int? index,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomerDialog(
          customer: customer,
          onSave: (newCustomer) {
           
          },
        );
      },
    );
  }
}
