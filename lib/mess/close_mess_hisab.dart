import 'package:flutter/material.dart';

class MessCloseScreen extends StatefulWidget {
  const MessCloseScreen({super.key});

  @override
  State<MessCloseScreen> createState() => _MessCloseScreenState();
}

class _MessCloseScreenState extends State<MessCloseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.green.shade100,
        child: Center(
          child: const Text("Visible on next update"),
        ),
      ),
    );  }
}