import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/src/locations.dart' as locations;
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
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

/*   Future<void> _goToCurrentLocation(GoogleMapController controller) async {
  // StreamSubscription<Position> positionStream;
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
  } */

  Future<void> _getCurrentLocation() async {
    print('_getCurrentLocation');
    final controller = await _controller.future;
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final _current = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 15);
    print('_currentPosition.latitude');
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
    print('hi');
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
      body: Stack(
        children: [
          SlidingUpPanel(
            // maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            backdropEnabled: true,
            body: _body(),
            panelBuilder: (sc) => _panel(sc),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    const _initialLocation = CameraPosition(
      target: LatLng(51.1657, 10.45),
      zoom: 12,
    );

    return GoogleMap(
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
