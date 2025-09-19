import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../customer/view/ui.dart';
import '../../dashboard/view/ui.dart';
import '../../new_sale/view/ui.dart';
import '../../product/view/ui.dart';
import '../../sales/view/ui.dart';
import '../view_model/wrapper_view_model.dart';

class WrapperScreen extends StatelessWidget {
  WrapperScreen({super.key});

  final List<Widget> _pages = [
    DashBoardScreen(),
    ProductScreen(),
    CustomersScreen(),
    NewSaleScreen(),
    SalesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WrapperViewModel>(context);
    return Scaffold(
      body: _pages[provider.currentindex],
      bottomNavigationBar: CurvedNavigationBar(
        color: PColors.primaryColor,
        backgroundColor: PColors.blackColor,
        index: provider.currentindex,
        onTap: (index) {
          provider.updateIndex(index);
        },
        items: const [
          Icon(Icons.dashboard_outlined),
          Icon(Icons.cake_outlined),
          Icon(Icons.people_outline),
          Icon(Icons.add_shopping_cart),
          Icon(Icons.receipt_long_outlined),
        ],
      ),
    );
  }
}
