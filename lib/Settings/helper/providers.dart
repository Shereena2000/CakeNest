import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import '../../Features/customer/view_model/customer_view_model.dart';
import '../../Features/dashboard/view_model.dart/dashboard_view_model.dart';
import '../../Features/product/view_model/view_model.dart';
import '../../Features/sales/view_model/sale_view_model.dart';
import '../../Features/wrapper/view_model/wrapper_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<WrapperViewModel>(create: (_) => WrapperViewModel()),
  ChangeNotifierProvider<CustomerViewModel>(create: (_) => CustomerViewModel()),
  ChangeNotifierProvider<ProductViewModel>(create: (_) => ProductViewModel()),
  ChangeNotifierProvider<SalesViewModel>(create: (_) => SalesViewModel()),
  ChangeNotifierProvider<DashboardViewModel>(create: (_) => DashboardViewModel()),
];