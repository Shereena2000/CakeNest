import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import '../../Features/wrapper/view_model/wrapper_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<WrapperViewModel>(create: (_) => WrapperViewModel()),
];
