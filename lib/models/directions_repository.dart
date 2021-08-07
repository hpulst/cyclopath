import 'dart:convert';

import 'package:cyclopath/models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/.config.dart';
import 'package:http/http.dart' as http;

class DirectionsRepository {
  final _baseUrl = 'maps.googleapis.com';
  final _basePath = '/maps/api/directions/json';

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final queryParameters = {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': googleAPIKey,
      'mode': 'bicycling',
    };

    final uri = Uri.https(_baseUrl, _basePath, queryParameters);
    print(uri);
    final response = await http.get(uri);

    // Check if response is successful
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return Directions.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
