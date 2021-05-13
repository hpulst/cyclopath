import 'package:cyclopath/custom_widgets/simple_dialog.dart';
import 'package:cyclopath/draggable/delivering_sheet.dart';
import 'package:cyclopath/draggable/offline_sheet.dart';
import 'package:cyclopath/draggable/waiting_sheet.dart';
import 'package:cyclopath/models/user_session.dart';
import 'package:cyclopath/models/destination.dart';
import 'package:cyclopath/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

GoogleMapController? mapController;

class AdaptiveNav extends StatefulWidget {
  @override
  _AdaptiveNavState createState() => _AdaptiveNavState();
}

class _AdaptiveNavState extends State<AdaptiveNav>
    with TickerProviderStateMixin {
  static const double _panelHeightClosed = 95.0;

  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');
  final double _initFabHeight = 120.0;
  final double _snapPoint = .45;

  double _panelHeightOpen = 0;
  VoidCallback? onSelected;
  double _fabHeight = 0;
  late AnimationController _dropArrowController;
  late PanelController _panelController;

  // @override
  // void didUpdateWidget(covariant AdaptiveNav oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   // if(oldWidget.isDeliveryMode != widget.isDeliveryMode){
  //   //   setState(() {

  //   //   });
  //   // }
  // }

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
      panelHeightClosed: 150,
      panelSnapping: false,
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
    // _getCurrentLocation();
    _panelController = PanelController();
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   if (_panelController.isAttached) {
    //     await _panelController.animatePanelToSnapPoint(curve: Curves.easeIn);
    //   }
    // },
    // );
  }

  // Future<void> _getCurrentLocation() async {
  //   final controller = await _controller.future;
  //   _currentPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   final _current = CameraPosition(
  //       target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
  //       zoom: 15);
  //   setState(() {
  //     controller.animateCamera(CameraUpdate.newCameraPosition(_current));
  //   });
  //   await _onMapCreated(controller);
  // }

  // Future<void> _onMapCreated(GoogleMapController controller) async {
  //   final googleOffices = await locations.getGoogleOffices();

  //   setState(
  //     () {
  //       _markers.clear();
  //       for (final office in googleOffices.offices!) {
  //         final marker = Marker(
  //           markerId: MarkerId(office.name!),
  //           position: LatLng(office.lat!, office.lng!),
  //           infoWindow: InfoWindow(
  //             title: office.name,
  //             snippet: office.address,
  //           ),
  //         );
  //         _markers[office.name] = marker;
  //       }
  //     },
  //   );
  // }

  // Widget _buildMap() {
  //   return GoogleMap(
  //     initialCameraPosition: _initialLocation,
  //     // mapToolbarEnabled: true,
  //     myLocationEnabled: true,
  //     myLocationButtonEnabled: false,
  //     zoomGesturesEnabled: true,
  //     zoomControlsEnabled: false,
  //     markers: _markers.values.toSet(),
  //     onMapCreated: (GoogleMapController controller) {
  //       if (!_controller.isCompleted) {
  //         _controller.complete(controller);
  //       } else {
  //         _controller.isCompleted;
  //       }
  //     },
  //   );
  // }

  Widget _bodyStack(context) {
    _panelHeightOpen = MediaQuery.of(context).size.height * .70;
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
            body: MapView(),
            panelBuilder: (_scrollController) => _BottomDrawerDestinations(
                panelController: _panelController,
                fabHeight: _fabHeight,
                scrollController: _scrollController),
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
            visible: false,
            // visible: _navigationDestinations
            //     .firstWhere((destination) =>
            //         destination.type == session.selectedUserSessionType)
            //     .locationButton,
            child: Positioned(
              right: 17.0,
              bottom: _fabHeight,
              child: FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () {},
                // onPressed: _getCurrentLocation,
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
            Icons.menu_rounded,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class _BottomDrawerDestinations extends StatelessWidget {
  _BottomDrawerDestinations({
    required this.panelController,
    required this.fabHeight,
    required this.scrollController,
  });

  final PanelController panelController;
  final double fabHeight;
  var scrollController;

  Widget _showBottomSheet({
    required PanelController panelController,
    required UserSessionType selectedUserSessionType,
  }) {
    switch (selectedUserSessionType) {
      case UserSessionType.offline:
        return OfflineSheet(
          panelController: panelController,
        );
      case UserSessionType.delivering:
        return DeliveringSheet(
          panelController: panelController,
        );
      default:
        return WaitingSheet(
          panelController: panelController,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedUserSessionType = context
        .select((UserSession session) => session.selectedUserSessionType);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        controller: scrollController,
        children: <Widget>[
          const SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12.0))),
              ),
            ],
          ),
          // const SizedBox(
          //   height: 8.0,
          // ),
          //GestureDetector seems to only work with ListView

          GestureDetector(
            onTap: () => panelController.panelPosition >= 0.1
                ? panelController.close()
                : panelController.open(),
            child: _showBottomSheet(
              selectedUserSessionType: selectedUserSessionType,
              panelController: panelController,
            ),
          ),
        ],
      ),
    );
  }
}
