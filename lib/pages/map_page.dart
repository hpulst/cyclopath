import 'dart:async';

import 'package:cyclopath/draggable_scrollable_sheets/delivering_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/offline_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/online_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/returning_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/waiting_sheet.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/utils/destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/models/locations.dart' as locations;
import 'package:provider/provider.dart';

const double _kFlingVelocity = 2.0;
const _kAnimationDuration = Duration(milliseconds: 300);
final Map<String?, Marker> _markers = {};
final Completer<GoogleMapController> _controller = Completer();
GoogleMapController? mapController;
late Position _currentPosition;

const _initialLocation = CameraPosition(
  target: LatLng(51.1657, 10.45),
  zoom: 12,
);

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');

  static const double minExtent = 0.12;
  static const double maxExtent = 0.6;

  double initialExtent = minExtent;
  bool isExpanded = false;
  // bool isVisible = true;
  late BuildContext draggableSheetContext;

  VoidCallback? onSelected;

  final _navigationDestinations = <Destination>[
    Destination(
      type: UserSessionType.offline,
      textLabel: UserSessionType.offline.title,
    ),
    Destination(
      type: UserSessionType.online,
      textLabel: UserSessionType.online.title,
      color: Colors.blueGrey,
      iconIsVisible: false,
    ),
    Destination(
      type: UserSessionType.waiting,
      textLabel: UserSessionType.offline.title,
    ),
    Destination(
      type: UserSessionType.delivering,
      textLabel: UserSessionType.offline.title,
    ),
    Destination(
      type: UserSessionType.returning,
      textLabel: UserSessionType.offline.title,
    ),
  ];

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
        for (final office in googleOffices.offices!) {
          final marker = Marker(
            markerId: MarkerId(office.name!),
            position: LatLng(office.lat!, office.lng!),
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

  Widget _buildMap(BuildContext context) {
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

  Widget _bodyStack(context) {
    return Stack(
      key: _bottomDrawerKey,
      children: [
        _buildMap(context),
        DraggableScrollableActuator(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent > minExtent) {
                setState(() {
                  isExpanded = true;
                });
                // print('moves
              } else if (notification.extent <= minExtent) {
                setState(() {
                  isExpanded = false;
                });
              }

              return true;
            },
            child: DraggableScrollableSheet(
              key: Key(initialExtent.toString()),
              minChildSize: minExtent,
              maxChildSize: maxExtent,
              initialChildSize: initialExtent,
              builder: _draggableScrollableSheetBuilder,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyStack(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Visibility(
          visible: !isExpanded,
          child: FloatingActionButton(
            onPressed: _getCurrentLocation,
            tooltip: 'Increment',
            child: const Icon(Icons.my_location),
          ),
        ),
      ),
    );
  }

  Widget _draggableScrollableSheetBuilder(context, scrollController) {
    draggableSheetContext = context;
    return Material(
      elevation: 100,
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Consumer<UserSession>(
          builder: (context, model, child) {
            return _draggableScrollableSheetContent(model, context);
          },
        ),
      ),
    );
  }

  Widget _draggableScrollableSheetContent(
      UserSession model, BuildContext context) {
    return Consumer<UserSession>(
      builder: (context, model, child) {
        return IndexedStack(
          index: model.selectedUserSessionTypeIndex,
          children: [
            OfflineSheet(
              model: model,
              toggleDraggableScrollableSheet: toggleDraggableScrollableSheet,
            ),
            OnlineSheet(model: model),
            WaitingSheet(
              model: model,
              toggleDraggableScrollableSheet: toggleDraggableScrollableSheet,
            ),
            DeliveringSheet(model: model),
            ReturningSheet(model: model),
          ],
        );
      },
    );
  }

  void toggleDraggableScrollableSheet() {
    print('hi voidcallback');
    setState(
      () {
        initialExtent = isExpanded ? minExtent : maxExtent;
        isExpanded = !isExpanded;
      },
    );
    DraggableScrollableActuator.reset(draggableSheetContext);
  }
}
