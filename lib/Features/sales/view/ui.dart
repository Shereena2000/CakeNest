import 'package:cake_nest/Features/common_widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import '../../../Settings/constants/sized_box.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sales History"),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text("Jhon", style: PTextStyles.bodyMedium),
              subtitle: Text(
                "2 items -19/9/2025",
                style: PTextStyles.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text("\$750", style: PTextStyles.labelMedium)],
              ),
              onTap: () => _showSaleDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaleDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: PColors.whiteColor,
          title: Text(
            'Sale Details - salesid1234',
            style: PTextStyles.displaySmall,
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Customer: ',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Jhon',
                        style: PTextStyles.bodySmall.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizeBoxH(8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Cuatomer ID:  ',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: '12',
                        style: PTextStyles.bodySmall.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizeBoxH(8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Date: ',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: '1992025   ', // extra space before Time
                        style: PTextStyles.bodySmall.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: 'Time: ',
                        style: PTextStyles.bodyMedium.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                      TextSpan(
                        text: '5:30',
                        style: PTextStyles.bodySmall.copyWith(
                          color: PColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizeBoxH(16),

                Text(
                  'Items:',
                  style: PTextStyles.bodyMedium.copyWith(
                    color: PColors.blackColor,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text(
                          "Choclate Cake",
                          style: PTextStyles.bodyMedium.copyWith(
                            color: PColors.blackColor,
                          ),
                        ),
                        subtitle: Text(
                          '3 x 75',

                          style: PTextStyles.bodySmall.copyWith(
                            color: PColors.blackColor,
                          ),
                        ),
                        trailing: Text(
                          '250',
                          style: PTextStyles.bodyMedium.copyWith(
                            color: PColors.blackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: PTextStyles.labelSmall.copyWith(
                        color: PColors.blackColor,
                      ),
                    ),
                    Text(
                      '\$250',
                      style: PTextStyles.labelSmall.copyWith(
                        color: PColors.blackColor,
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
  }
}
