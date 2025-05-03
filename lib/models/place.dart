import 'dart:io';

import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation(
      {required this.latititude,
      required this.longitude,
      required this.address});
  final double latititude;
  final double longitude;
  final String address;
}

class Place {
  final String id;
  final String title;
  final File image;
  final String location;

  Place({
    required this.title,
    required this.image,
    required this.location,
  })
  //  required this.location})
  : id = uuid.v4();

  // final PlaceLocation location;
}
