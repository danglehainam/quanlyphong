import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormat {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('vi_VN');

  /// Formats a number with thousand separators (e.g., 1.000.000)
  static String format(num value) {
    if (value == 0) return '0';
    try {
      return _formatter.format(value);
    } catch (e) {
      return value.toString();
    }
  }

  /// Parses a formatted string back to an integer
  static int parse(String value) {
    if (value.isEmpty) return 0;
    try {
      return _formatter.parse(value).toInt();
    } catch (e) {
      // Fallback: strip all non-digit characters and parse
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return 0;
      return int.parse(digits);
    }
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Only allow digits
    String numericOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (numericOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = int.parse(numericOnly);
    final formattedText = CurrencyFormat.format(value);

    // Keep the cursor position at the end
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
