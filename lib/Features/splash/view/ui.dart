import 'package:cake_nest/Settings/constants/sized_box.dart';
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
          SizeBoxH(130),
          Text(
            "Cake Nest",
            style: PTextStyles.displayLarge.copyWith(
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: const Color.fromARGB(255, 112, 2, 2),
              fontSize: 35,
            ),
          ),
          SizeBoxH(30),
          CircularProgressIndicator(
            color: const Color.fromARGB(255, 112, 2, 2),
          ),
        ],
      ),
    );
  }

  void checkLogin() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        PPages.wrapperPageUi,
        (route) => false,
      );
    });
  }
}
