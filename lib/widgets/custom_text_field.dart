import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  final String? labelText;
  bool? isObscure = true;
  bool? enabled = true;

  CustomTextField(
      {super.key,
      this.controller,
      this.data,
      this.hintText,
      this.labelText,
      this.isObscure,
      this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10.0),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObscure!,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
          prefixIcon: Icon(data, color: Colors.black,),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
          labelText: labelText,
        ),
      ),
    );
  }
}
