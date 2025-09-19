import 'package:cake_nest/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  FloatingActionButton(
      shape: CircleBorder(),
        backgroundColor: PColors.primaryColor,
        onPressed: onPressed,
          
        child:  Icon(
          Icons.add,
          color: PColors.whiteColor,
        ),
      );
  }
}