import 'dart:async';

import 'package:cyclopath/custom_widgets/simple_dialog.dart';
import 'package:cyclopath/models/destination_model.dart';
import 'package:cyclopath/models/directions_model.dart';
import 'package:cyclopath/models/directions_repository.dart';
import 'package:cyclopath/models/locations.dart' as locations;
import 'package:cyclopath/models/map_model.dart';
import 'package:cyclopath/models/order_list_model.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bottom_drawer.dart';

// static const double _initFabHeight = 220.0;
const double storeLatitudeHamburg = 53.55744486901641;
const double storeLongitudeHamburg = 9.989580614218664;

const initialTarget = LatLng(storeLatitudeHamburg, storeLongitudeHamburg);
const _initialLocation = CameraPosition(
  target: initialTarget,
  zoom: 12,
);

class AdaptiveNav extends StatefulWidget {
  @override
  _AdaptiveNavState createState() => _AdaptiveNavState();
}

class _AdaptiveNavState extends State<AdaptiveNav>
    with TickerProviderStateMixin {
  static const double _initFabHeight = _panelHeightClosed + 105;
  static const double _panelHeightClosed = 95.0;

  late BitmapDescriptor customIcon;
  late PanelController _panelController;
  late Position _currentPosition;
  late Directions directions;

  final Completer<GoogleMapController> _controller = Completer();
  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  final double _snapPoint = .45;

  double _panelHeightOpen = 0;
  double _fabHeight = 0;

  // final Map<PolylineId, Polyline> _polylines = {};

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
        locationButton: false,
        navigationButton: false),
    Destination(
      type: UserSessionType.delivering,
      textLabel: UserSessionType.delivering.title,
      showIcon: false,
      panelHeightOpen: .70,
      // panelHeightClosed: _panelHeightClosed,
      panelHeightClosed: 190,
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
      // panelHeightOpen: .70,
      panelHeightClosed: 170,
      panelSnapping: false,
      // initFabHeight: _initFabHeight + 160,
      locationButton: true,
      navigationButton: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setCameraToCurrentLocation();
    _panelController = PanelController();
  }

  Future<void> _getCurrentPosition() async {
    final orderModel = context.read<OrderListModel>();
    await orderModel.getCurrentPosition();
    _currentPosition = orderModel.currentPosition;
  }

  Future<void> _setCameraToCurrentLocation() async {
    final mapController = await _controller.future;
    await _getCurrentPosition();

    setState(
      () {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    _currentPosition.latitude, _currentPosition.longitude),
                zoom: 14),
          ),
        );
      },
    );
  }

  Future<void> _setCameraToRoute() async {
    final model = context.read<OrderListModel>();
    final mapController = await _controller.future;
    setState(
      () {
        mapController.showMarkerInfoWindow(MarkerId(model.currentOrder.id));
        mapController.animateCamera(
          model.polylines.isNotEmpty
              ? CameraUpdate.newLatLngBounds(model.directions.bounds, 100.0)
              : CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: LatLng(model.currentPosition.latitude,
                          model.currentPosition.longitude),
                      zoom: 14),
                ),
        );
      },
    );
  }

  Future<void> _launchMapsUrl() async {
    final model = context.read<OrderListModel>();

    final lat = model.destinationLatitude;
    final lng = model.destinationLongitude;

    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=bicycling&dir_action=navigate';

    // final appleMapsUrl = 'https://maps.apple.com/?q=$lat,$lng';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
      // }
      // else if (await canLaunch(appleMapsUrl)) {
      //   await launch(appleMapsUrl);

    } else {
      throw 'Could not launch URL';
    }
  }

  Widget _buildMap() {
    return Consumer<OrderListModel>(
      builder: (context, model, _) {
        return GoogleMap(
          mapToolbarEnabled: true,

          initialCameraPosition: _initialLocation,
          // mapToolbarEna
          //bled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,

          markers: Set<Marker>.of(model.markers.values),
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            } else {
              _controller.isCompleted;
            }
          },
          polylines: Set<Polyline>.of(model.polylines.values),
          padding: const EdgeInsets.only(bottom: 100),
        );
      },
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
                getCurrentLocation: _setCameraToCurrentLocation,
                setRoute: _setCameraToRoute),
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
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'btn1',
                    onPressed: () {
                      _setCameraToCurrentLocation();
                    },
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.gps_fixed,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton(
                    heroTag: 'btn0',
                    onPressed: () {
                      _launchMapsUrl();
                    },
                    backgroundColor: Colors.blue[900],
                    child: Icon(
                      Icons.directions,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
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
