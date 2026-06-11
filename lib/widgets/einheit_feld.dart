import 'package:flutter/material.dart';

class EinheitFeld extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String einheit;
  final String? hintText;
  final int maxLines;

  const EinheitFeld({
    super.key,
    required this.controller,
    required this.label,
    required this.einheit,
    this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: einheit,
      ),
    );
  }
}