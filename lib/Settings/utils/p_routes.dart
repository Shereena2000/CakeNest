import 'package:cake_nest/Features/wrapper/view/ui.dart';
import 'package:flutter/material.dart';

import '../../Features/splash/view/ui.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case PPages.wrapperPageUi:
        return MaterialPageRoute(builder: (context) => WrapperScreen());

      default:
        return null;
    }


  }
}
