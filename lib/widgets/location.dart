import 'dart:convert';

import 'package:favourite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  //
  PlaceLocation? _pickedLocation;

  //boolean variable for checking whether location is getting or not
  var isGettingLocation = false;

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lat = _pickedLocation!.latititude;
    final long = _pickedLocation!.longitude;

    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C$lat,$long&key=AIzaSyBOopFLzv7GKLbTUUj8c_Z6Fssfrh_wpok';
  }

  //
  //get current location
  void _selectOnMap() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      isGettingLocation = true;
    });

    //object for location
    locationData = await location.getLocation();

    //get latititude and longitude
    final lat = locationData.latitude;
    final long = locationData.longitude;
    print(lat);
    // check
    if (lat == null || long == null) {
      const NotificationListener(child: Text('Invalid Latitude and Longitude'));
      return;
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=AIzaSyBOopFLzv7GKLbTUUj8c_Z6Fssfrh_wpok');
    final response = await http.get(url);
    final responseData = jsonDecode(response.body);
    final address = responseData['results'][1]['formatted_address'];
    print(responseData);
    //
    setState(() {
      //picked location
      _pickedLocation =
          PlaceLocation(latititude: lat, longitude: long, address: address);
      isGettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = const Text(
      'No location',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    );

    //peview static maps
    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    //check is isGetting location
    if (isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor)),
          height: 160,
          width: double.infinity,
          child: previewContent, //preview content
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.location_on),
              label: const Text('Get current location'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
