import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/widgets/location.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.place});

  final Place place;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        title: Text(
          place.title,
          style: const TextStyle(color: Colors.amberAccent),
        ),
      ),
      body: Stack(
        //stack is used here to place multiple widget on top of each other
        children: [
          Image.file(
            place.image,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
