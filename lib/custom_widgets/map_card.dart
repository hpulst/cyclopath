// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cyclopath/models/locations.dart' as locations;

// class MapCard extends StatefulWidget {
//   const MapCard({Key? key}) : super(key: key);

//   @override
//   _MapCardState createState() => _MapCardState();
// }

// class _MapCardState extends State<MapCard> {
//   final _initialLocation = const CameraPosition(
//     target: LatLng(51.1657, 10.45),
//     zoom: 12,
//   );

//   final Map<String?, Marker> _markers = {};
//   final Completer<GoogleMapController> _controller = Completer();
//   GoogleMapController? mapController;
//   late Position _currentPosition;

//   @override
//   void initState() {
//     getCurrentLocation();
//     super.initState();
//   }

//   Future<void> getCurrentLocation() async {
//     final controller = await _controller.future;
//     _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     final _current = CameraPosition(
//         target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//         zoom: 15);
//     setState(() {
//       controller.animateCamera(CameraUpdate.newCameraPosition(_current));
//     });
//     await _onMapCreated(controller);
//   }

//   Future<void> _onMapCreated(GoogleMapController controller) async {
//     final googleOffices = await locations.getGoogleOffices();

//     setState(
//       () {
//         _markers.clear();
//         for (final office in googleOffices.offices!) {
//           final marker = Marker(
//             markerId: MarkerId(office.name!),
//             position: LatLng(office.lat!, office.lng!),
//             infoWindow: InfoWindow(
//               title: office.name,
//               snippet: office.address,
//             ),
//           );
//           _markers[office.name] = marker;
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       initialCameraPosition: _initialLocation,
//       myLocationEnabled: true,
//       myLocationButtonEnabled: false,
//       zoomGesturesEnabled: true,
//       zoomControlsEnabled: false,
//       markers: _markers.values.toSet(),
//       onMapCreated: (GoogleMapController controller) {
//         if (!_controller.isCompleted) {
//           _controller.complete(controller);
//         } else {
//           _controller.isCompleted;
//         }
//       },
//     );
//   }
// }
