import 'package:cake_nest/Settings/constants/sized_box.dart';
import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:cake_nest/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../Settings/utils/p_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 400,

            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/splash4.jpg"),
                fit: BoxFit.cover, // 👈 optional (cover, contain, fill etc.)
              ),
            ),
          ),
          SizeBoxH(70),
          Text(
            "Cake Nest",
            style: PTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: const Color.fromARGB(255, 112, 2, 2),
              fontSize: 35,
            ),
          ),
        ],
      ),

      // body: Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: const BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage("assets/images/splash4.jpg"),
      //       fit: BoxFit.cover, // 👈 optional (cover, contain, fill etc.)
      //     ),
      //   ),
      //   child: Column(
      //     children: [
      //       const Spacer(flex: 5), // empty space (takes 3 parts)
      //       Text(
      //         "Cake Nest",
      //         style: PTextStyles.displayLarge.copyWith(
      //           fontWeight: FontWeight.w800,
      //           fontStyle: FontStyle.italic,
      //           color: const Color.fromARGB(255, 132, 10, 1),
      //         ),
      //       ),
      //       const Spacer(flex: 2), // empty space below (takes 2 parts)
      //     ],
      //   ),
      // ),
    );
  }

  void checkLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      // if (!mounted) return;
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   PPages.wrapperPageUi,
      //   (route) => false,
      // );
    });
  }
}
