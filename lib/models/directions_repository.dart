import 'dart:convert';

import 'package:cyclopath/models/directions_model.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/.config.dart';
import 'package:http/http.dart' as http;

// class DirectionsRepository {
//   final _baseUrl = 'maps.googleapis.com/';
//   final _basePath = 'maps/api/directions/json?';

//   Future<Directions> getDirections({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     final queryParameters = {
//       'origin': '${origin.latitude},${origin.longitude}',
//       'destination': '${destination.latitude},${destination.longitude}',
//       'key': googleAPIKey,
//     };

//     final uri = Uri.http(
//         'maps.googleapis.com', '/maps/api/directions/json?', queryParameters);

//     final response = await http.get(uri);

//     // Check if response is successful
//     if (response.statusCode == 200) {
//       return Directions.fromMap(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to load directions');
//     }
//   }
// }

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleAPIKey,
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      print(response.statusMessage);
      return Directions.fromMap(response.data);
    }
    throw Exception('Failed to load directions');
  }
}
