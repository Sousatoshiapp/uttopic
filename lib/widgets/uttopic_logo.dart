import 'package:flutter/material.dart';

class UttopicLogo extends StatelessWidget {
  final double size;

  const UttopicLogo({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'U',
          style: TextStyle(
            color: Colors.black,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}