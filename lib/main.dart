import 'package:flutter/material.dart';
import 'package:item_identifier/core/app_initializer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Image Recognition',
      theme: ThemeData.dark(),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}