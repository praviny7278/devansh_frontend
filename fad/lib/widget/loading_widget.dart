import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Positioned(
      top: 220,
      left: 100,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 180,
          height: 180,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(0.5),
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 8,
            color: Colors.black45,
          ),
        ),
      ),
    );
  }
}
