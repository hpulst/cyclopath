import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/.config.dart';

class DirectionsRepository {
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  Future<void> _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    if (polylines.isNotEmpty) {
      polylines.clear();
    }
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.bicycling,
    );

    if (result.points.isNotEmpty) {
      if (polylineCoordinates.isNotEmpty) {
        polylineCoordinates.clear();
      }
      for (final point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }

    const id = PolylineId('poly');
    final polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
  }
}
