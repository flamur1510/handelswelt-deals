import 'package:flutter/material.dart';

class InseratKarte extends StatelessWidget {
  final String? titel;
  final Widget child;

  const InseratKarte({
    super.key,
    this.titel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffececf4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titel != null) ...[
            Text(
              titel!,
              style: const TextStyle(
                color: Color(0xff050b2c),
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class InseratFeld extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const InseratFeld({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class InseratDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const InseratDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sichererWert =
        items.contains(value) ? value : items.first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: sichererWert,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xfff7f7fb),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}