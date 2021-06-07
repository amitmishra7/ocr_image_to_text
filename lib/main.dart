import 'package:flutter/material.dart';
import 'package:ocr_image_to_text/ocr_page.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'OCR',home:OCRPage());
  }
}