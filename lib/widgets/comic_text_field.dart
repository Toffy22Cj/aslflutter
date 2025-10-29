import 'package:flutter/material.dart';

class ComicTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const ComicTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.icon,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 50, right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontFamily: 'Bangers',
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Bangers',
                  fontSize: 18,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (icon != null)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Icon(
                icon,
                color: Colors.black,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}