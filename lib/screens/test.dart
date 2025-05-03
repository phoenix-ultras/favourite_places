import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class testapp extends StatefulWidget {
  const testapp({super.key});

  @override
  State<testapp> createState() => _testappState();
}

class _testappState extends State<testapp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text(
          'data',
          style: TextStyle(),
        ),
      ),
    );
  }
}
