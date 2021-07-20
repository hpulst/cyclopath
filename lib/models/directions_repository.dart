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

    final response = await http.get(uri);

    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load directions');
    }
  }
}  

// try {
//   //404
//   await dio.get('https://wendux.github.io/xsddddd');
// } on DioError catch (e) {
//   // The request was made and the server responded with a status code
//   // that falls out of the range of 2xx and is also not 304.
//   if (e.response) {
//     print(e.response.data)
//     print(e.response.headers)
//     print(e.response.request)
//   } else {
//     // Something happened in setting up or sending the request that triggered an Error
//     print(e.request)
//     print(e.message)
//   }
// }

// class DirectionsRepository {
//   static const String _baseUrl =
//       'https://maps.googleapis.com/maps/api/directions/json?';

//   Future<Directions> getDirections({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     try {
//       final response = await Dio().get(
//         // 'https://maps.googleapis.com/maps/api/directions/json?origin=Disneyland&destination=Universal+Studios+Hollywood&key=$googleAPIKey'
//         _baseUrl,
//         queryParameters: {
//           'origin': '${origin.latitude},${origin.longitude}',
//           'destination': '${destination.latitude},${destination.longitude}',
//           'key': googleAPIKey,
//           'mode': 'bicycling',
//           // 'mode': 'transit',
//         },  
//       );

//       // Check if response is successful
//       print(response.statusMessage);
//       if (response.statusCode == 200 &&
//           (response.data['routes'] as List).isNotEmpty) {
//         return Directions.fromMap(response.data);
//       }
//     } on Exception catch (e) {
//       print(e);
//     }
//     throw Exception('Failed to load directions');
//   }
// }
