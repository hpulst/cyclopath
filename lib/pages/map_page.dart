import 'dart:async';

import 'package:cyclopath/custom_widgets/simple_dialog.dart';
import 'package:cyclopath/draggable/delivering_sheet.dart';
import 'package:cyclopath/draggable/offline_sheet.dart';
import 'package:cyclopath/draggable/waiting_sheet.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/models/destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/models/locations.dart' as locations;
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
  final double _initFabHeight = 120.0;

  late AnimationController _dropArrowController;
  late PanelController _panelController;

  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  double _panelHeightClosed = 95.0;
  VoidCallback? onSelected;

  final _navigationDestinations = <Destination>[
    Destination(
      type: UserSessionType.offline,
      textLabel: UserSessionType.offline.title,
      showIcon: false,
    ),
    Destination(
      type: UserSessionType.online,
      textLabel: UserSessionType.online.title,
      showIcon: false,
    ),
    Destination(
      type: UserSessionType.waiting,
      textLabel: UserSessionType.waiting.title,
      showIcon: false,
    ),
    Destination(
      type: UserSessionType.delivering,
      textLabel: UserSessionType.delivering.title,
      showIcon: false,
    ),
    Destination(
      type: UserSessionType.returning,
      textLabel: UserSessionType.returning.title,
      showIcon: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _panelController = PanelController();
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   if (_panelController.isAttached) {
    //     await _panelController.animatePanelToSnapPoint(curve: Curves.easeIn);
    //   }
    // },
    // );
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
      // mapToolbarEnabled: true,
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
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Material(
      child: Stack(
        key: _bottomDrawerKey,
        // alignment: Alignment.topCenter,
        children: [
          SlidingUpPanel(
            controller: _panelController,
            maxHeight: _panelHeightOpen,
            minHeight: _panelHeightClosed,
            parallaxEnabled: true,
            parallaxOffset: .5,
            snapPoint: .41,
            body: _buildMap(context),
            panelBuilder: (sc) {
              return _BottomDrawerDestinations(
                destinations: _navigationDestinations,
                panelController: _panelController,
              );
            },
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
            onPanelSlide: (double pos) => setState(() {
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),
          Positioned(
            right: 17.0,
            bottom: _fabHeight,
            child: FloatingActionButton(
              heroTag: "btn1",
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.gps_fixed,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyStack(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: FloatingActionButton(
          heroTag: "btn2",
          onPressed: () {
            showDialog(
                context: context, builder: (_) => const SimpleDialogWidget());
          },
          child: const Icon(
            Icons.menu_rounded,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  const _BottomDrawerDestinations({
    required this.panelController,
    required this.destinations,
  });

  final PanelController panelController;
  final List<Destination>? destinations;

  Widget _showBottomSheet({
    required UserSession model,
    required PanelController panelController,
  }) {
    switch (model.selectedUserSessionType) {
      case UserSessionType.offline:
        return OfflineSheet(
          panelController: panelController,
        );
      case UserSessionType.delivering:
        return DeliveringSheet(
          model: model,
          panelController: panelController,
        );
      default:
        return WaitingSheet(
          model: model,
          panelController: panelController,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSession>(
      builder: (context, model, child) {
        return Center(
          child: GestureDetector(
            onTap: () => panelController.panelPosition >= 0.4
                ? panelController.close()
                : panelController.animatePanelToSnapPoint(),
            child: _showBottomSheet(
              model: model,
              panelController: panelController,
            ),
          ),
        );
      },
    );
  }
}
