import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;
  const ErrorDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          child: const Center(
            child: Text("OK"),
          ),
        )
      ],
    );
  }
}
