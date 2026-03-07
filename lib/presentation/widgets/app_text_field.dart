import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isLoading;
  final bool isNumber;
  final bool isRequired;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isLoading = false,
    this.isNumber = false,
    this.isRequired = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: !isLoading,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines != null && maxLines! > 1,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          if (isNumber && value != null && value.isNotEmpty && int.tryParse(value) == null) {
            return 'Vui lòng nhập số hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}
