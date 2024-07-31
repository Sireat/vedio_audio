import 'package:flutter/material.dart';
import 'file_uploader_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Audio App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileUploaderScreen(),
    );
  }
}
