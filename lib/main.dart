import 'package:flutter/material.dart';
import 'screens/screen.dart';

void main() => runApp(const ImageSelectorApp());

class ImageSelectorApp extends StatelessWidget {
  const ImageSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageSelectorScreen(),
    );
  }
}