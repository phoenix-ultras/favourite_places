import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favourite_places/widgets/location.dart';
import 'package:favourite_places/widgets/places_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favourite_places/provider.dart/user_place.dart';
import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/widgets/input_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class NewPlace extends ConsumerStatefulWidget {
  const NewPlace({
    super.key,
  });

  @override
  ConsumerState<NewPlace> createState() {
    return _NewPlace();
  }
}

class _NewPlace extends ConsumerState<NewPlace> {
  //formkey
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle;
  var _enteredLocation;
  var latitude;
  var longitude;

  //access selected image
  File? _selectedImage;
  Future<void> getCurrentLocation() async {
    //checking permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Allow permission to open maps");
      LocationPermission permission = await Geolocator.requestPermission();
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return const SpinKitWaveSpinner(
              color: Colors.black,
            );
          });
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      latitude = currentPosition.latitude;
      longitude = currentPosition.longitude;
      //dismiss dialog box
      Navigator.of(context).pop();

      Fluttertoast.showToast(
          msg: "Fetched Current location $latitude and $longitude");
    }

    //updating values
    ref.read(locationProvider.notifier).update((location) {
      location['latitude'] = latitude;
      location['longitude'] = longitude;
      return location;
    });
  }

  //add place method
  void _addPlace() async {
    final _enteredPlace = Place(
      title: _enteredTitle.toString(),
      image: _selectedImage!,
      location: _enteredLocation!,
    );
    if (_selectedImage == null || _enteredLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select image and location')));
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        //loading spinner
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return const SpinKitWaveSpinner(
                color: Colors.black,
              );
            });
        //upload image to firestorage
        final imageref = FirebaseStorage.instance.ref().child('users_place');

        Reference toUpload = imageref.child(_enteredTitle);
        await toUpload.putFile(_selectedImage!);

        //image url
        String imageUrl = await toUpload.getDownloadURL();

        //uploading to firestore
        final placeref =
            FirebaseFirestore.instance.collection('user_place').doc();
        //map to store credientials
        Map<String, String> placeMap = {
          'id': placeref.id,
          'title': _enteredTitle,
          'url': imageUrl,
          'location': _enteredPlace.location,
        };

        //dismiss loading spinner
        Navigator.of(context).pop();

        await placeref.set(placeMap);
        Fluttertoast.showToast(msg: 'Uploaded successfully');
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    //using provider method
    ref.read(userPlaceProvider.notifier).addPlace(_enteredPlace);

    Navigator.of(context).pop(
      Place(
        title: _enteredTitle,
        image: _selectedImage!,
        location: _enteredLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 199, 219, 230),
        appBar: AppBar(
          backgroundColor: Colors.brown,
          title: const Text('Swachh Bharat',
              style: TextStyle(color: Color.fromARGB(255, 3, 3, 2))),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: const TextStyle(
                        color: Color.fromARGB(255, 9, 1, 1), fontSize: 20),
                    maxLength: 15,
                    onSaved: (value) {
                      _enteredTitle = value;
                    },
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1) {
                        return 'Enter valid Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Image Input
                  ImageInput(
                    onPickImage: (image) {
                      _selectedImage = image;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    child: TextField(
                      onChanged: (value) {
                        _enteredLocation = value;
                      },
                      style: const TextStyle(
                          color: Color.fromARGB(255, 8, 6, 0), fontSize: 20),
                      decoration: const InputDecoration(
                        label: Text('Enter location'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                      onPressed: getCurrentLocation,
                      label: const Text('Get current loation')),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown),
                      onPressed: _addPlace,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Place',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
