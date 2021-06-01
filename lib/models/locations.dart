import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'locations.g.dart';

@JsonSerializable()
class LatLng {
  LatLng({
    this.lat,
    this.lng,
  });

  factory LatLng.fromJson(Map<String, dynamic> json) => _$LatLngFromJson(json);
  Map<String, dynamic> toJson() => _$LatLngToJson(this);

  final double? lat;
  final double? lng;
}

@JsonSerializable()
class Region {
  Region({
    this.coords,
    this.id,
    this.name,
    this.zoom,
  });

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
  Map<String, dynamic> toJson() => _$RegionToJson(this);

  final LatLng? coords;
  final String? id;
  final String? name;
  final double? zoom;
}

@JsonSerializable()
class Office {
  Office({
    this.address,
    this.id,
    this.image,
    this.lat,
    this.lng,
    this.name,
    this.phone,
    this.region,
  });

  factory Office.fromJson(Map<String, dynamic> json) => _$OfficeFromJson(json);
  Map<String, dynamic> toJson() => _$OfficeToJson(this);

  final String? address;
  final String? id;
  final String? image;
  final double? lat;
  final double? lng;
  final String? name;
  final String? phone;
  final String? region;
}

@JsonSerializable()
class Locations {
  Locations({
    this.offices,
    this.regions,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final List<Office>? offices;
  final List<Region>? regions;
}

// Future<Locations> getOffices() async {
//   const googleLocationsURL = 'https://about.google/static/data/locations.json';

//   // Retrieve the locations of Google offices
//   try {
//     // final response = await http.get(Uri.parse(googleLocationsURL));

//     var a = Locations.fromJson(json.decode());

//     if (response.statusCode == 200) {
//       print('response.decode${json.decode(response.body)}');

//       return Locations.fromJson(json.decode(response.body));
//     } else {
//       throw HttpException(
//           'Unexpected status code ${response.statusCode}:'
//           ' ${response.reasonPhrase}',
//           uri: Uri.parse(googleLocationsURL));
//     }
//   } catch (err, stacktrace) {
//     print(err);
//     return Locations();
//   }
// }

Future<Locations> getOffices() async {
  final jsonLocations = await _loadAssets();

  return Locations.fromJson(json.decode(jsonLocations));
}

Future<String> _loadAssets() {
  return rootBundle.loadString('assets/json/offices.json');
}
