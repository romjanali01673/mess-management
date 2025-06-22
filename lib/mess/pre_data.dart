import 'package:flutter/material.dart';

class PreDataScreen extends StatefulWidget {
  const PreDataScreen({super.key});

  @override
  State<PreDataScreen> createState() => _PreDataScreenState();
}

class _PreDataScreenState extends State<PreDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: Container(
        color: Colors.green.shade100,
        child: Center(
          child: const Text("Visible on next update"),
        ),
      ),
    );
  }
}