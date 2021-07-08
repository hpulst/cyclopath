import 'dart:async';

import 'package:cyclopath/custom_widgets/simple_dialog.dart';
import 'package:cyclopath/models/destination_model.dart';
import 'package:cyclopath/models/directions_model.dart';
import 'package:cyclopath/models/directions_repository.dart';
import 'package:cyclopath/models/locations.dart' as locations;
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'bottom_drawer.dart';

Set<Marker> _markers = {};

final Completer<GoogleMapController> _controller = Completer();

late Position _currentPosition;
late Directions directions;
// late GoogleMapController mapController;

const _initialTarget = LatLng(51.1657, 10.45);
const _initialLocation = CameraPosition(
  target: _initialTarget,
  zoom: 12,
);

class AdaptiveNav extends StatefulWidget {
  @override
  _AdaptiveNavState createState() => _AdaptiveNavState();
}

class _AdaptiveNavState extends State<AdaptiveNav>
    with TickerProviderStateMixin {
  static const double _panelHeightClosed = 95.0;
  static const double _initFabHeight = _panelHeightClosed + 105;
  // static const double _initFabHeight = 220.0;
  late BitmapDescriptor customIcon;

  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  final double _snapPoint = .45;

  double _panelHeightOpen = 0;
  double _fabHeight = 0;
  // late AnimationController _dropArrowController;
  late PanelController _panelController;

  // late Directions directions = Directions(
  //     bounds: LatLngBounds(
  //       southwest: _initialTarget,
  //       northeast: _initialTarget,
  //     ),
  //     polylinePoints: [],
  //     totalDistance: '0.0',
  //     totalDuration: '0');
  final Map<PolylineId, Polyline> _polylines = {};

  final _navigationDestinations = <Destination>[
    Destination(
      type: UserSessionType.offline,
      textLabel: UserSessionType.offline.title,
      showIcon: false,
      panelHeightOpen: .70,
      panelHeightClosed: _panelHeightClosed,
      panelSnapping: true,
      locationButton: false,
      navigationButton: false,
    ),
    Destination(
      type: UserSessionType.online,
      textLabel: UserSessionType.online.title,
      showIcon: false,
      panelHeightClosed: _panelHeightClosed,
      panelSnapping: true,
      locationButton: false,
      navigationButton: false,
    ),
    Destination(
      type: UserSessionType.waiting,
      textLabel: UserSessionType.waiting.title,
      showIcon: false,
      panelHeightClosed: _panelHeightClosed,
      panelSnapping: true,
      locationButton: true,
      navigationButton: true,
    ),
    Destination(
      type: UserSessionType.delivering,
      textLabel: UserSessionType.delivering.title,
      showIcon: false,
      panelHeightOpen: .70,
      // panelHeightClosed: _panelHeightClosed,
      panelHeightClosed: 170,
      // panelSnapping: true,
      panelSnapping: false,
      initFabHeight: _initFabHeight + 160,
      locationButton: true,
      navigationButton: true,
    ),
    Destination(
      type: UserSessionType.returning,
      textLabel: UserSessionType.returning.title,
      showIcon: false,
      panelHeightClosed: _panelHeightClosed,
      panelSnapping: false,
      locationButton: true,
      navigationButton: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _onMapCreated();
    _setCameraToCurrentLocation();
    _panelController = PanelController();
  }

  Future<void> _onMapCreated() async {
    final offices = await locations.getOffices();
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(10, 10)),
        'assets/images/green_salad_windows.png');

    _markers.clear();
    for (final office in offices.offices!) {
      final marker = Marker(
        markerId: MarkerId(office.name!),
        position: LatLng(office.lat!, office.lng!),
        icon: customIcon,
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: office.name,
          snippet: office.address,
        ),
      );
      _markers.add(marker);
    }
  }

  Future<void> _getCurrentPosition() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _setCameraToCurrentLocation() async {
    print(StackTrace.current);

    final mapController = await _controller.future;
    await _getCurrentPosition();
    final _current = CameraPosition(
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 14);
    setState(() {
      mapController.animateCamera(CameraUpdate.newCameraPosition(_current));
    });
    if (context.read<UserSession>().selectedUserSessionType ==
        UserSessionType.delivering) {
      await _addOrderMarkers();
    }
  }

  Future<void> _addOrderMarkers() async {
    final model = context.read<OrderListModel>();
    final mapController = await _controller.future;

    if (_markers.isNotEmpty) {
      _markers.clear();
    }
    _markers.addAll(model.markers);

    await _getCurrentPosition();

    // print(model.currentOrder.street);

    directions = await DirectionsRepository().getDirections(
        origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        destination: LatLng(model.currentOrder.lat, model.currentOrder.lng));

    await _createPolylines(
        _currentPosition.latitude,
        _currentPosition.longitude,
        model.currentOrder.lat,
        model.currentOrder.lng);

    setState(
      () {
        print('${_polylines.isNotEmpty} bounds ${directions.bounds}');
        mapController.animateCamera(
          _polylines.isNotEmpty
              ? CameraUpdate.newLatLngBounds(directions.bounds, 100.0)
              : CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(_currentPosition.latitude,
                          _currentPosition.longitude),
                      zoom: 14),
                ),
        );
      },
    );
  }

  Future<void> getDirections(OrderListModel model) async {}

  Future<void> _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    if (_polylines.isNotEmpty) {
      _polylines.clear();
    }

    const id = PolylineId('poly');
    final polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      width: 6,
      points: directions.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
    );
    _polylines[id] = polyline;

    // _changeInfo(_markers);
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: _initialLocation,
      // mapToolbarEna
      //bled: true,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      markers: _markers,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        } else {
          _controller.isCompleted;
        }
      },
      polylines: Set<Polyline>.of(_polylines.values),
    );
  }

  Widget _bodyStack(context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * 1;
    Destination destination;

    return Stack(
      key: _bottomDrawerKey,
      children: [
        Consumer<UserSession>(builder: (context, session, _) {
          destination = _navigationDestinations.firstWhere((destination) =>
              destination.type == session.selectedUserSessionType);

          return SlidingUpPanel(
            controller: _panelController,
            maxHeight: _panelHeightOpen,
            minHeight: destination.panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            snapPoint: .48,
            panelSnapping: destination.panelSnapping,
            backdropEnabled: true,
            backdropOpacity: 0,
            backdropTapClosesPanel: true,
            body: _buildMap(),
            panelBuilder: (_scrollController) => BottomDrawerDestinations(
                panelController: _panelController,
                fabHeight: _fabHeight,
                scrollController: _scrollController,
                getCurrentLocation: _setCameraToCurrentLocation),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          );
        }),
        Consumer<UserSession>(builder: (context, session, _) {
          return Visibility(
            visible: _navigationDestinations
                .firstWhere((destination) =>
                    destination.type == session.selectedUserSessionType)
                .locationButton,
            child: Positioned(
              right: 17.0,
              bottom: _fabHeight,
              child: FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () {
                  _setCameraToCurrentLocation();
                },
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.gps_fixed,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        }),
        // Positioned(
        //     top: 0,
        //     child: ClipRRect(
        //         child: BackdropFilter(
        //             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //             child: Container(
        //               width: MediaQuery.of(context).size.width,
        //               height: MediaQuery.of(context).padding.top,
        //               color: Colors.transparent,
        //             )))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyStack(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          heroTag: 'btn2',
          onPressed: () {
            showDialog(
                context: context, builder: (_) => const SimpleDialogWidget());
          },
          child: const Icon(
            Icons.more_vert_rounded,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
