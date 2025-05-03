import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/provider.dart/user_place.dart';
import 'package:favourite_places/screens/place_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

// class PlacesList extends StatefulWidget {

//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _PlaceList();
//   }

// class _PlaceList extends State<PlacesList>  {
//   @override
//   Widget build(BuildContext context) {
//     if (places.isEmpty) {
//       return const Center(
//         child: Text(
//           'No Places added yet!',
//           style: TextStyle(color: Colors.white),
//         ),
//       );
//     }
//     return ListView.builder(
//       itemCount: places.length,
//       itemBuilder: (ctx, index) {
//         return Container(
//           margin: EdgeInsets.only(top: 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: const Color.fromARGB(255, 225, 132, 132),
//           ),
//           // color: const Color.fromARGB(255, 225, 132, 132),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundImage: FileImage(places[index].image),
//             ),
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => DetailScreen(
//                     place: places[index],
//                   ),
//                 ),
//               );
//             },
//             title: Column(
//               children: [
//                 Text(
//                   places[index].title,
//                   style: TextStyle(color: Colors.black),
//                 ),
//                 Text(
//                   places[index].location,
//                   style: TextStyle(color: Colors.black),
//                 )
//               ],
//             ),
//             titleTextStyle: const TextStyle(fontSize: 25),
//           ),
//         );
//       },
//     );
//   }}

// }
class PlacesList extends ConsumerStatefulWidget {
  PlacesList({super.key});

  @override
  ConsumerState<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends ConsumerState<PlacesList> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> placeStream;
  late double? latitude;
  late double? longitude;

  @override
  void initState() {
    // TODO: implement initState

    //accessing from firestore
    placeStream =
        FirebaseFirestore.instance.collection('user_place').snapshots();

    super.initState();
  }

  //direct to google maps
  void googleMaps() async {
    //riverpod used to access latitude and longitude
    final currentLocation = ref.watch(locationProvider);
    latitude = currentLocation['latitude']!;
    longitude = currentLocation['longitude']!;

    print(latitude);
    if (latitude == null || longitude == null) {
      Fluttertoast.showToast(msg: "Some error occured");
    }

    //url for map
    Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');

    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      Fluttertoast.showToast(
          msg: "Could not open map.please check your internet connectivity");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: placeStream,
        builder: (context, AsyncSnapshot snapshot) {
          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 10),
                    margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 6,
                            spreadRadius: 1),
                      ],
                    ),
                    child: GestureDetector(
                        child: Text(
                          ds['title'],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              actions: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 5, right: 1),
                                          height: 100,
                                          width: 100,
                                          child: Image.network(
                                            ds['url'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          ds['title'],
                                          style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    //Entered location
                                    Text(
                                      ds['location'],
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        googleMaps();
                                      },
                                      label: const Text(
                                        'Open in Maps',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      icon: const Icon(
                                        Icons.map,
                                        size: 20,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                ],
              );
            },
          );
        });
  }
}
