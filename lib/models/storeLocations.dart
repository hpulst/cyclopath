import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'storeLocations.g.dart';

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

Future getOffices(String homeStoreId) async {
  var office = Office();

  try {
    final jsonLocations = await _loadAssets();
    final locations = Locations.fromJson(json.decode(jsonLocations));
    return office =
        locations.offices!.firstWhere((element) => element.id == homeStoreId);
  } on Exception catch (e) {
    debugPrint('Error caught: $e');
    return office;
  }
}

Future<String> _loadAssets() {
  return rootBundle.loadString('assets/json/offices.json');
}
