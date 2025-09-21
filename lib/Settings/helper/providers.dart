import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import '../../Features/customer/view_model/customer_view_model.dart';
import '../../Features/wrapper/view_model/wrapper_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<WrapperViewModel>(create: (_) => WrapperViewModel()),

  ChangeNotifierProvider<CustomerViewModel>(create: (_) => CustomerViewModel()),
];
