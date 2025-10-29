import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final bool show;
  final String? message;

  const Loader({Key? key, required this.show, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: show,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD322)),
            strokeWidth: 6,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontFamily: 'Bangers',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ],
      ),
    );
  }
}