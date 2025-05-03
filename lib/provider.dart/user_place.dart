import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favourite_places/models/place.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPlaceNotifier extends StateNotifier<List<Place>> {
  UserPlaceNotifier() : super(const []);
  Future<void> addPlace(Place place) async {
    //provider method for adding place that user enters
    final newPlace = Place(
      title: place.title,
      image: place.image,
      location: place.location,
    );

    //updating provider
    state = [newPlace, ...state];
  }
}

final userPlaceProvider = StateNotifierProvider((ref) => UserPlaceNotifier());

//store latitude and longitude in riverpod
final locationProvider = StateProvider((ref) {
  return {'latitude': 0.0, 'longitude': 0.0};
});
