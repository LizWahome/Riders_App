import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
        Colors.amber,
      ),
    ),
  ); 
}
