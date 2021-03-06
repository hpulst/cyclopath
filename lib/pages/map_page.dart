import 'dart:async';

import 'package:cyclopath/util/bottom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/src/locations.dart' as locations;

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _initialLocation = const CameraPosition(
    target: LatLng(51.1657, 10.45),
    zoom: 12,
  );

  final Map<String, Marker> _markers = {};
  // double _panelHeightOpen;
  final double _panelHeightClosed = 95.0;
  final Completer<GoogleMapController> _controller = Completer();

  GoogleMapController mapController;
  Position _currentPosition;

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
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
          _AnimatedBottomAppBar(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 98.0),
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        controller: sc,
        children: [
          const SizedBox(
            height: 30.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: <Widget>[
              const Icon(
                Icons.keyboard_arrow_up,
                size: 30,
              ),
              const SizedBox(width: 50),
              const Text(
                'Du bist offline',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
          const SizedBox(
            height: 36.0,
          ),
        ],
      ),
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
