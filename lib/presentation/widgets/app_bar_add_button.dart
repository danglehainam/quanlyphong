import 'package:flutter/material.dart';

class AppBarAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const AppBarAddButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
