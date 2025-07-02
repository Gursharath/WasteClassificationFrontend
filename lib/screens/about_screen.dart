import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Recycle Smart")),
      body: const Center(
        child: Text("Recycle Smart is a waste classification app using AI."),
      ),
    );
  }
}
