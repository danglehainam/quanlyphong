import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isLoading;
  final bool isNumber;
  final bool isCurrency;
  final bool isRequired;
  final bool readOnly;
  final int? maxLines;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isLoading = false,
    this.isNumber = false,
    this.isCurrency = false,
    this.isRequired = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !isLoading,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        keyboardType: isNumber || isCurrency ? TextInputType.number : TextInputType.text,
        inputFormatters: isCurrency ? [CurrencyInputFormatter()] : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: maxLines != null && maxLines! > 1,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: suffixIcon,
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
