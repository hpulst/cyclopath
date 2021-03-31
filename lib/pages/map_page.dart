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

  static const double minExtent = 0.12;
  static const double maxExtent = 0.6;

  double initialExtent = minExtent;
  bool isExpanded = false;
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
          child: DraggableScrollableSheet(
            key: Key(initialExtent.toString()),
            minChildSize: minExtent,
            maxChildSize: maxExtent,
            initialChildSize: initialExtent,
            builder: _draggableScrollableSheetBuilder,
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
        child: isExpanded
            ? null
            : FloatingActionButton(
                onPressed: _getCurrentLocation,
                tooltip: 'Increment',
                child: const Icon(Icons.my_location),
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
    return Column(
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
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            IconButton(
              icon: const Icon(Icons.expand_less),
              iconSize: 30,
              onPressed: _toggleDraggableScrollableSheet,
            ),
            const SizedBox(
              width: 1,
            ),
            Expanded(
              child: Text(
                '${model.selectedUserSessionType.title}',
                style: TextStyle(fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 45,
            ),
          ],
        ),
        const Divider(
          height: 20,
        ),
        ShiftStarts(),
        // Container(
        //   height: 200,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       ElevatedButton(
        //         onPressed: () {
        //           _toggleDraggableScrollableSheet();
        //           context.read<UserSession>().selectedUserSessionType =
        //               UserSessionType.offline;
        //         },
        //         child: const Text('Go online'),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  void _toggleDraggableScrollableSheet() {
    if (draggableSheetContext != null) {
      setState(
        () {
          initialExtent = isExpanded ? minExtent : maxExtent;
          isExpanded = !isExpanded;
        },
      );
    }

    DraggableScrollableActuator.reset(draggableSheetContext);
  }
}

// class _AnimatedBottomAppBar extends StatelessWidget {
//   const _AnimatedBottomAppBar({
//     this.toggleBottomDrawerVisibility,
//     this.bottomDrawerVisible,
//     this.dropArrowCurve,
//     this.destinations,
//     this.selectedUserSessionType,
//   });

//   final bool? bottomDrawerVisible;
//   final Animation<double>? dropArrowCurve;
//   final ui.VoidCallback? toggleBottomDrawerVisibility;
//   final List<Destination>? destinations;
//   final UserSessionType? selectedUserSessionType;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsetsDirectional.only(top: 2),
//       child: BottomAppBar(
//         // elevation: 10.0,
//         child: Container(
//           height: 80.0,
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               InkWell(
//                 borderRadius: const BorderRadius.all(Radius.circular(16)),
//                 onTap: toggleBottomDrawerVisibility,
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 20),
//                     RotationTransition(
//                       turns: Tween(
//                         begin: 0.0,
//                         end: 1.0,
//                       ).animate(dropArrowCurve!),
//                       child: const Icon(
//                         Icons.expand_less,
//                         size: 30,
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Text(
//                       destinations!.firstWhere((item) {
//                         return item.type == selectedUserSessionType;
//                       }).textLabel!,
//                       style: Theme.of(context).textTheme.headline5,
//                     ),
//                     const SizedBox(width: 20),
//                   ],
//                 ),
//               ),
//               const Expanded(
//                   child: Align(
//                 alignment: Alignment.centerRight,
//                 child: Icon(
//                   Icons.playlist_play,
//                 ),
//               )),
//               const SizedBox(width: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BottomDrawerDestinations extends StatelessWidget {
//   _BottomDrawerDestinations({
//     this.drawerController,
//     this.dropArrowController,
//     this.selectedUserSessionType,
//     this.destinations,
//   });

//   final AnimationController? drawerController;
//   final AnimationController? dropArrowController;
//   final List<Destination>? destinations;
//   final UserSessionType? selectedUserSessionType;

//   final TimeOfDay now = TimeOfDay.now();
//   final DateTime timely =
//       DateTime.now().subtract(Duration(minutes: TimeOfDay.now().minute % 5));

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ListView(
//         padding: const EdgeInsets.all(12),
//         physics: const NeverScrollableScrollPhysics(),
//         children: [
//           Column(
//             children: [
//               const SizedBox(
//                 height: 3.0,
//               ),
//               Container(
//                 width: 30,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(12.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Schichtstart',
//                 style: Theme.of(context).textTheme.headline5,
//               ),
//               const SizedBox(height: 20),
//               ShiftStarts(
//                 drawerController: drawerController,
//                 dropArrowController: dropArrowController,
//               ),
//               const IconButton(
//                 iconSize: 50.0,
//                 onPressed: null,
//                 icon: Icon(Icons.stop_circle_outlined),
//               ),
//               const Text('Offline'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class ShiftStarts extends StatelessWidget {
  // ShiftStarts(
  // {
  // @required this.drawerController,
  // @required this.dropArrowController,
  // required this.onItemTapped,
  // }
  // );

  // final AnimationController? drawerController;
  // final AnimationController? dropArrowController;
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
              // drawerController!.reverse();
              // dropArrowController!.reverse();
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
