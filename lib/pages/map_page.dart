import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/src/locations.dart' as locations;

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final CameraPosition _initialLocation = const CameraPosition(
    target: LatLng(0.0, 0.0),
    // target: LatLng(53.557192580892306, 9.98927563086055),
    zoom: 12,
  );
  final Map<String, Marker> _markers = {};

  GoogleMapController mapController;
  Position _currentPosition;
  StreamSubscription<Position> positionStream;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  Future<void> _goToCurrentLocation(GoogleMapController controller) async {
    positionStream = Geolocator.getPositionStream().listen(
      (Position position) {
        setState(() {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
              ),
            ),
          );
        });
      },
    );

    return positionStream;
  }

  Future<void> _getCurrentLocation() async {
    final controller = await _controller.future;
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final _current = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 15);

    setState(() {
      controller.animateCamera(CameraUpdate.newCameraPosition(_current));
    });
    await _onMapCreated(controller);
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();

    setState(
      () {
        _markers.clear();
        for (final office in googleOffices.offices) {
          final marker = Marker(
            markerId: MarkerId(office.name),
            position: LatLng(office.lat, office.lng),
            infoWindow: InfoWindow(
              title: office.name,
              snippet: office.address,
            ),
          );
          _markers[office.name] = marker;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Stadtsalat'),
      //   backgroundColor: Colors.transparent,
      //   centerTitle: true,
      // ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 98.0),
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          child: const Icon(Icons.my_location),
        ),
      ),
      // bottomSheet: Container(
      //   child: Text('Hi, this is a test'),
      // ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers.values.toSet(),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              } else {
                _controller.isCompleted;
              }
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.1,
            builder: (context, scrollController) {
              return Container(
                color: Colors.white,
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 25,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        leading: const Icon(Icons.my_location),
                        title: Text('Item $index'));
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
