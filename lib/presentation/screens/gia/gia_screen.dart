import 'package:flutter/material.dart';

class GiaScreen extends StatelessWidget {
  const GiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng giá'),
      ),
      body: const Center(
        child: Text(
          'Màn hình Bảng giá',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
