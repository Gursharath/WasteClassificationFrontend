import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waste Tips")),
      body: const Center(
        child: Text("Tips on how to reduce, reuse and recycle!"),
      ),
    );
  }
}
