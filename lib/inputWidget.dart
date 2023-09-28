import 'package:flutter/material.dart';

class inputText extends StatelessWidget {
  const inputText({
    Key? key,
    this.label,
    required this.hint,
    this.validate = false,
    this.maxLines,
    this.controller,
    this.obscureText = false,
  }) : super(key: key);

  final String? label;
  final String hint;
  final bool validate;
  final int? maxLines;
  final bool obscureText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.white,
          labelText: hint,
          hintStyle: const TextStyle(fontWeight: FontWeight.w900),
          labelStyle: TextStyle(fontWeight: FontWeight.w900),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black)),
        ),
        validator: validate
            ? (String? value) {
                if (value == null || value.isEmpty) {
                  return 'please enter some text';
                }
                return null;
              }
            : null,
      ),
    );
  }
}

class SignInputWidget extends StatelessWidget {
  const SignInputWidget({
    Key? key,
    required this.hint,
    required this.icon,
    this.controller,
    this.hintStyle, required this.obscureText,
  }) : super(key: key);

  final String hint;
  final Icon icon;
  final TextStyle? hintStyle;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(
        top: 20,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 5.0,
          right: 16.0,
          left: 16.0,
        ),
        child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              icon: icon,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: hintStyle,
            ),
            obscureText: obscureText,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'please enter some text';
              }
              return null;
            }),
      ),
    );
  }
}

InputDecoration inputFormFields(String label, String hint) {
  return InputDecoration(
      hintText: label,
      fillColor: Colors.white,
      labelText: hint,
      enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.horizontal(),
          borderSide: BorderSide(color: Colors.black)));
}

