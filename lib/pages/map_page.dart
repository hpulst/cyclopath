import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cyclopath/custom_widgets/bottom_drawer.dart';
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

  late AnimationController _drawerController;
  late AnimationController _dropArrowController;

  late AnimationController _bottomAppBarController;
  late Animation<double> _drawerCurve;
  late Animation<double>? _dropArrowCurve;
  late Animation<double>? _bottomAppBarCurve;
  VoidCallback? onSelected;

  final _navigationDestinations = <Destination>[
    Destination(
      type: UserSessionType.offline,
      textLabel: UserSessionType.offline.title,
    ),
    Destination(
      type: UserSessionType.online,
      textLabel: UserSessionType.online.title,
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _drawerController = AnimationController(
      value: 0,
      duration: _kAnimationDuration,
      vsync: this,
    )..addListener(
        () {
          if (_drawerController.value < 0.01) {
            setState(() {});
          }
        },
      );

    _dropArrowController = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );

    _bottomAppBarController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 250),
    );

    _drawerCurve = CurvedAnimation(
      parent: _drawerController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _dropArrowCurve = CurvedAnimation(
      parent: _dropArrowController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _bottomAppBarCurve = CurvedAnimation(
      parent: _bottomAppBarController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _dropArrowController.dispose();
    _bottomAppBarController.dispose();
    super.dispose();
  }

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  double get _bottomDrawerHeight {
    final renderBox =
        _bottomDrawerKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
        velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta! / _bottomDrawerHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_drawerController.isAnimating ||
        _drawerController.status == AnimationStatus.completed) {
      return;
    }

    final flingVelocity =
        details.velocity.pixelsPerSecond.dy / _bottomDrawerHeight;

    if (flingVelocity < 0.0) {
      _drawerController.fling(
        velocity: math.max(_kFlingVelocity, -flingVelocity),
      );
    } else if (flingVelocity > 0.0) {
      _dropArrowController.forward();
      _drawerController.fling(
        velocity: math.min(-_kFlingVelocity, -flingVelocity),
      );
    } else {
      if (_drawerController.value < 0.6) {
        _dropArrowController.forward();
      }
      _drawerController.fling(
        velocity:
            _drawerController.value < 0.6 ? -_kFlingVelocity : _kFlingVelocity,
      );
    }
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

  Widget _bodyStack(context, constraints) {
    final drawerSize = constraints.biggest;
    final drawerTop = drawerSize.height;

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Stack(
      key: _bottomDrawerKey,
      children: [
        _buildMap(context),
        GestureDetector(
          onTap: () {
            _drawerController.reverse();
            _dropArrowController.reverse();
          },
          child: Visibility(
            maintainAnimation: true,
            maintainState: true,
            visible: _bottomDrawerVisible,
            child: FadeTransition(
              opacity: _drawerCurve,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
              ),
            ),
          ),
        ),
        PositionedTransition(
          rect: drawerAnimation,
          child: Visibility(
            visible: _bottomDrawerVisible,
            child: BottomDrawer(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              leading: Consumer<UserSession>(
                builder: (context, model, child) {
                  return _BottomDrawerDestinations(
                    drawerController: _drawerController,
                    dropArrowController: _dropArrowController,
                    selectedUserSessionType: model.selectedUserSessionType,
                    destinations: _navigationDestinations,
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: _bodyStack),
      floatingActionButton: _bottomDrawerVisible
          ? null
          : FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: const Icon(
                Icons.my_location,
                size: 30,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _AnimatedBottomAppBar(
        bottomDrawerVisible: _bottomDrawerVisible,
        toggleBottomDrawerVisibility: _toggleBottomDrawerVisibility,
        dropArrowCurve: _dropArrowCurve,
      ),
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  const _AnimatedBottomAppBar({
    this.toggleBottomDrawerVisibility,
    this.bottomDrawerVisible,
    this.dropArrowCurve,
  });

  final bool? bottomDrawerVisible;
  final Animation<double>? dropArrowCurve;
  final ui.VoidCallback? toggleBottomDrawerVisibility;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 2),
      child: BottomAppBar(
        // elevation: 10.0,
        child: Container(
          height: 80.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                onTap: toggleBottomDrawerVisibility,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    RotationTransition(
                      turns: Tween(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(dropArrowCurve!),
                      child: const Icon(
                        Icons.arrow_drop_up,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Du bist offline',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
              const Expanded(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.playlist_play,
                ),
              )),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  _BottomDrawerDestinations({
    @required this.drawerController,
    @required this.dropArrowController,
    @required this.destinations,
    @required this.selectedUserSessionType,
  });

  final AnimationController? drawerController;
  final AnimationController? dropArrowController;
  final List<Destination>? destinations;
  final UserSessionType? selectedUserSessionType;

  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(12),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            children: [
              const SizedBox(
                height: 3.0,
              ),
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Schichtstart um',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 20),
              ShiftStarts(
                drawerController: drawerController,
                dropArrowController: dropArrowController,
              ),
              const IconButton(
                iconSize: 50.0,
                onPressed: null,
                icon: Icon(Icons.stop_circle_outlined),
              ),
              const Text('Offline'),
            ],
          ),
        ],
      ),
    );
  }
}

class ShiftStarts extends StatelessWidget {
  ShiftStarts({
    @required this.drawerController,
    @required this.dropArrowController,
    // required this.onItemTapped,
  });

  final AnimationController? drawerController;
  final AnimationController? dropArrowController;
  // final void Function(DateTime, UserSessionType) onItemTapped;

  final TimeOfDay now = TimeOfDay.now();
  final DateTime timely =
      DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

  @override
  Widget build(BuildContext context) {
    final timingButtons = <Widget>[];

    for (var i = 0; i < 6; i++) {
      timingButtons.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            onPressed: () {
              drawerController!.reverse();
              dropArrowController!.reverse();
              context.read<UserSession>().selectedUserSessionType =
                  UserSessionType.online;
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
              minimumSize: const Size(260, 0.0),
            ),
            child: Text(i < 2
                ? i < 1
                    ? '${TimeOfDay.fromDateTime(DateTime.now().subtract(Duration(minutes: now.minute % 5))).format(context)} (vor ${now.minute % 5} Minuten)'
                    : 'JETZT'
                : TimeOfDay.fromDateTime(
                    timely.add(
                      Duration(minutes: 5 * (i - 1)),
                    ),
                  ).format(context)),
          ),
        ),
        // const SizedBox(height: 10),
      );
    }

    return Column(
      children: timingButtons,
    );
  }
}
