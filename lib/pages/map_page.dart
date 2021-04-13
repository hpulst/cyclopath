import 'dart:async';
import 'dart:math' as math;

import 'package:cyclopath/custom_widgets/bottom_drawer.dart';
import 'package:cyclopath/draggable_scrollable_sheets/delivering_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/offline_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/online_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/returning_sheet.dart';
import 'package:cyclopath/draggable_scrollable_sheets/waiting_sheet.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/models/destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/models/locations.dart' as locations;
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

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
  late Animation<double> _dropArrowCurve;
  late Animation<double> _bottomAppBarCurve;
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
      reverseCurve: standardEasing,
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

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      // _bottomAppBarController.reverse();
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
      velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity,
    );
  }

  double get _bottomDrawerHeight {
    final renderBox =
        _bottomDrawerKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.size.height;
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

  // bool _handleScrollNotification(ScrollNotification notification) {
  //   if (notification.depth == 0) {
  //     if (notification is UserScrollNotification) {
  //       switch (notification.direction) {
  //         case ScrollDirection.forward:
  //           _bottomAppBarController.forward();
  //           break;
  //         case ScrollDirection.reverse:
  //           _bottomAppBarController.reverse();
  //           break;
  //         case ScrollDirection.idle:
  //           break;
  //       }
  //     }
  //   }
  //   return false;
  // }

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
        // NotificationListener(
        //   onNotification: _handleScrollNotification,
        //   child: _buildMap(context),
        // ),
        GestureDetector(
          onTap: () {
            _drawerController.reverse();
            _dropArrowController.reverse();
            // _bottomAppBarController.forward();
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
                    model: model,
                    drawerController: _drawerController,
                    dropArrowController: _dropArrowController,
                    destinations: _navigationDestinations,
                    bottomAppBarController: _bottomAppBarController,
                  );
                },
              ),
            ),
          ),
        ),
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
      bottomNavigationBar: Consumer<UserSession>(
        builder: (context, model, child) {
          return _AnimatedBottomAppBar(
            bottomAppBarController: _bottomAppBarController,
            bottomAppBarCurve: _bottomAppBarCurve,
            drawerController: _drawerController,
            bottomDrawerVisible: _bottomDrawerVisible,
            dropArrowCurve: _dropArrowCurve,
            selectedUserSessionType: model.selectedUserSessionType,
            destinations: _navigationDestinations,
            toggleBottomDrawerVisibility: _toggleBottomDrawerVisibility,
          );
        },
      ),
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  const _AnimatedBottomAppBar({
    required this.bottomAppBarController,
    required this.bottomAppBarCurve,
    required this.bottomDrawerVisible,
    required this.drawerController,
    this.dropArrowCurve,
    this.destinations,
    this.selectedUserSessionType,
    this.toggleBottomDrawerVisibility,
  });

  final AnimationController bottomAppBarController;
  final Animation<double> bottomAppBarCurve;
  final bool bottomDrawerVisible;
  final AnimationController drawerController;
  final Animation<double>? dropArrowCurve;
  final List<Destination>? destinations;
  final UserSessionType? selectedUserSessionType;
  final VoidCallback? toggleBottomDrawerVisibility;

  @override
  Widget build(BuildContext context) {
    final fadeOut = Tween<double>(begin: 1, end: -1).animate(
      drawerController.drive(
        CurveTween(curve: standardEasing),
      ),
    );

    // if (selectedUserSessionType == UserSessionType.delivering) {
    //   bottomAppBarController.reverse();
    // } else {
    //   bottomAppBarController.forward();
    // }
    // bottomAppBarController.forward();

    return SizeTransition(
      sizeFactor: bottomAppBarCurve,
      axisAlignment: -1,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: 2),
        child: BottomAppBar(
          // elevation: 10.0,
          child: Material(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              onTap: toggleBottomDrawerVisibility,
              child: Container(
                height: 80.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        RotationTransition(
                          turns: Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(dropArrowCurve!),
                          child: const Icon(
                            Icons.expand_less,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 40),
                        _FadeThroughTransitionSwitcher(
                          fillColor: Colors.transparent,
                          child: bottomDrawerVisible
                              ? const SizedBox(width: 48)
                              : FadeTransition(
                                  opacity: fadeOut,
                                  child: Text(
                                      destinations!.firstWhere((item) {
                                        return item.type ==
                                            selectedUserSessionType;
                                      }).textLabel!,
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                      textAlign: TextAlign.center),
                                ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // const Icon(
                    //   Icons.playlist_play,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  const _BottomDrawerDestinations({
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
    required this.bottomAppBarController,
    this.destinations,
  });

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;
  final AnimationController bottomAppBarController;
  final List<Destination>? destinations;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OfflineSheet(
        model: model,
        drawerController: drawerController,
        dropArrowController: dropArrowController,
      ),
      // child: Positioned(
      //   child: IndexedStack(
      //     index: model.selectedUserSessionTypeIndex,
      //     children: [
      //       OfflineSheet(
      //         model: model,
      //         drawerController: drawerController,
      //         dropArrowController: dropArrowController,
      //       ),
      //       OnlineSheet(model: model),
      //       WaitingSheet(
      //         model: model,
      //         drawerController: drawerController,
      //         dropArrowController: dropArrowController,
      //       ),
      //       DeliveringSheet(
      //         model: model,
      //         drawerController: drawerController,
      //         dropArrowController: dropArrowController,
      //         bottomAppBarController: bottomAppBarController,
      //       ),
      //       ReturningSheet(model: model),
      //     ],
      //   ),
      // ),
    );
  }
}

class _FadeThroughTransitionSwitcher extends StatelessWidget {
  const _FadeThroughTransitionSwitcher({
    this.fillColor,
    this.child,
  });
  final Widget? child;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return FadeThroughTransition(
          fillColor: fillColor,
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
        );
      },
      child: child,
    );
  }
}

class OfflineSheet extends StatelessWidget {
  const OfflineSheet({
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
  });

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            const SizedBox(
              height: 6.0,
            ),
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                drawerController.reverse();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeliveringSheet(
                          model: model,
                          drawerController: drawerController,
                          dropArrowController: dropArrowController)),
                );
              },
              child: const Text('First'),
            ),
          ],
        ),
      ],
    );
  }
}

class DeliveringSheet extends StatelessWidget {
  const DeliveringSheet({
    required this.model,
    required this.drawerController,
    required this.dropArrowController,
  });

  final UserSession model;
  final AnimationController drawerController;
  final AnimationController dropArrowController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          children: [
            const SizedBox(
              height: 6.0,
            ),
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Second'),
            ),
          ],
        ),
      ],
    );
  }
}
