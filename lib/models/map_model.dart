// import 'package:flutter/material.dart';
// import 'dart:async';

// import 'package:cyclopath/custom_widgets/simple_dialog.dart';
// import 'package:cyclopath/models/destination_model.dart';
// import 'package:cyclopath/models/directions_model.dart';
// import 'package:cyclopath/models/directions_repository.dart';
// import 'package:cyclopath/models/locations.dart' as locations;
// import 'package:cyclopath/models/order_list_model.dart';
// import 'package:cyclopath/models/user_session.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';

// // late GoogleMapController mapController;

// const _initialTarget = LatLng(51.1657, 10.45);
// const _initialLocation = CameraPosition(
//   target: _initialTarget,
//   zoom: 12,
// );

// class MapModel extends ChangeNotifier {
//   final Set<Marker> _markers = {};
//   final Map<PolylineId, Polyline> _polylines = {};

//   late Directions _directions;
//   late Position _currentPosition;
//   late BitmapDescriptor customIcon;

//   Set<Marker> get markers => _markers;
//   Map<PolylineId, Polyline> get polylines => _polylines;
//   Position get currentPosition => _currentPosition;
//   Directions get directions => _directions;

//   Future<void> onMapCreated() async {
//     final offices = await locations.getOffices();
//     customIcon = await BitmapDescriptor.fromAssetImage(
//         const ImageConfiguration(size: Size(10, 10)),
//         'assets/images/green_salad_windows.png');

//     _markers.clear();
//     for (final office in offices.offices!) {
//       final marker = Marker(
//         markerId: MarkerId(office.name!),
//         position: LatLng(office.lat!, office.lng!),
//         icon: customIcon,
//         // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: InfoWindow(
//           title: office.name,
//           snippet: office.address,
//         ),
//       );
//       _markers.add(marker);
//     }
//   }

//   Future<void> getCurrentPosition() async {
//     _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   Future<void> addOrderMarkers(OrderListModel model) async {
//     if (_markers.isNotEmpty) {
//       _markers.clear();
//     }
//     _markers.addAll(model.markers);

//     // await getCurrentPosition();

//     // TODO(master): is there a better way then to call getDirections from here?
//     await setDirections(model.currentOrder.lat, model.currentOrder.lng);

//     // await _createPolylines(
//     //     _currentPosition.latitude,
//     //     _currentPosition.longitude,
//     //     model.currentOrder.lat,
//     //     model.currentOrder.lng);

//     // setState(
//     //   () {
//     //     print('${_polylines.isNotEmpty} bounds ${directions.bounds}');
//     //     mapController.animateCamera(
//     //       _polylines.isNotEmpty
//     //           ? CameraUpdate.newLatLngBounds(directions.bounds, 100.0)
//     //           : CameraUpdate.newCameraPosition(
//     //               CameraPosition(
//     //                   target: LatLng(_currentPosition.latitude,
//     //                       _currentPosition.longitude),
//     //                   zoom: 14),
//     //             ),
//     //     );
//     //   },
//     // );
//   }

//   Future<void> setDirections(double latitude, double longitude) async {
//     _directions = await DirectionsRepository().getDirections(
//         origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
//         destination: LatLng(latitude, longitude));
//     notifyListeners();
//     await createPolylines();
//   }

//   Future<void> createPolylines() async {
//     if (_polylines.isNotEmpty) {
//       _polylines.clear();
//     }

//     const id = PolylineId('poly');
//     final polyline = Polyline(
//       polylineId: id,
//       color: Colors.black,
//       width: 6,
//       points: _directions.polylinePoints
//           .map((e) => LatLng(e.latitude, e.longitude))
//           .toList(),
//     );
//     _polylines[id] = polyline;
//   }
// }
