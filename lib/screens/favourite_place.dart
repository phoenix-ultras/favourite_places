import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/screens/new_place.dart';
import 'package:favourite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';

class FavouritePlace extends StatefulWidget {
  const FavouritePlace({
    super.key,
  });

  @override
  State<FavouritePlace> createState() {
    return _FavouritePlaceState();
  }
}

class _FavouritePlaceState extends State<FavouritePlace> {
  final List<Place> _newPlaces = [];

  //function to be executed when button add place is pressed
  void addPlace() async {
    final newPlaceItem = await Navigator.of(context).push<Place>(
      MaterialPageRoute(builder: (context) => const NewPlace()),
    );

    if (newPlaceItem != null) {
      setState(() {
        _newPlaces.add(newPlaceItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title:
            const Text('Swachh Bharat', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: addPlace,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PlacesList(),
    );
  }
}
