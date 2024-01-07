import 'package:flutter/material.dart';

Widget buildTextField(String labelText, TextEditingController textController,
    bool isPasswordTextField) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 25.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextField(
          obscureText: isPasswordTextField ? true : false,
          enabled: true,
          decoration: const InputDecoration(
            filled: false,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            fillColor: Colors.black45,
          ),
          style: const TextStyle(color: Colors.black, height: 0.75),
          autofocus: false,
          controller: textController,
          keyboardType: TextInputType.none,
          textInputAction: isPasswordTextField
              ? TextInputAction.done
              : TextInputAction.next,
        ),
      ],
    ),
  );
}