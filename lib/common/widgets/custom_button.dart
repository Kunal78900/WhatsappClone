import 'package:flutter/material.dart';


import '../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // ignore: deprecated_member_use
        primary: tabColor,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}