import 'package:cake_nest/Features/customer/repository/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Data/core/database_helper.dart';
import 'Settings/helper/providers.dart';
import 'Settings/utils/p_colors.dart';
import 'Settings/utils/p_pages.dart';
import 'Settings/utils/p_routes.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();
    await DatabaseHelper().deleteDatabase();
  // Initialize Supabase
  await SupabaseService().initialize();
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'CakeNest',
      theme: ThemeData(
        brightness: Brightness.dark,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: PColors.color000000,
        colorScheme: ColorScheme.fromSeed(
          seedColor: PColors.primaryColor,
          brightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: PColors.whiteColor),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: PColors.color000000,
          surfaceTintColor: PColors.color000000,
          foregroundColor: PColors.whiteColor,
          centerTitle: true,
        ),
      ),
      initialRoute: PPages.splash,
      onGenerateRoute: Routes.genericRoute,
    );
  }
}

// void configLoading() {
//   EasyLoading.instance
//     ..loadingStyle = EasyLoadingStyle.custom
//     ..backgroundColor = Colors.white
//     ..maskColor = Colors.white
//     ..indicatorColor = Colors.black
//     ..userInteractions = false
//     ..dismissOnTap = false
//     ..textColor = Colors.transparent
//     ..contentPadding = const EdgeInsets.all(8)
//     ..textPadding = EdgeInsets.zero
//     ..indicatorType = EasyLoadingIndicatorType.ring
//     ..indicatorSize = 23
//     ..lineWidth = 2.2
//     ..radius = 20
//     ..boxShadow = <BoxShadow>[
//       const BoxShadow(offset: Offset(2, 2), blurRadius: 10, color: Color.fromRGBO(0, 0, 0, .15)),
//     ];
// }
