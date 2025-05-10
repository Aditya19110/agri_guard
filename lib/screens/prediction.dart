import 'dart:io';
import 'package:flutter/material.dart';

class PredictionPage extends StatelessWidget {
  final File? imageFile;

  const PredictionPage({Key? key, this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction')),
      body: Center(
        child: imageFile != null
            ? Image.file(imageFile!)
            : const Text("No image selected."),
      ),
    );
  }
}
