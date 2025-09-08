
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatefulWidget {
  final Uint8List PdfFile;
  const PdfPreviewScreen({super.key, required this.PdfFile});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        backgroundColor: Colors.grey,
      ),
      body: InteractiveViewer(
        child: PdfPreview(
          build: (format) => widget.PdfFile,
        ),
      ),
    );
  }
}



