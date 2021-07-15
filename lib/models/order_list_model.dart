import 'package:cyclopath/custom_widgets/adaptive_navi.dart';
import 'package:cyclopath/utils/json_parsing.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/models/locations.dart' as locations;

import 'directions_model.dart';
import 'directions_repository.dart';
import 'order.dart';

class OrderListModel extends ChangeNotifier {
  OrderListModel({
    required this.repository,
    List<Order>? orderQueue,
  }) : _orderQueue = orderQueue ?? [];

  final List<Order> _orderQueue;
  final OrderRepository repository;
  final Set<Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  final String _selectedOrder = '';

  bool _isLoading = false;

  late Directions _directions;
  late Position _currentPosition;
  late BitmapDescriptor customIcon;

  Map<PolylineId, Polyline> get polylines => _polylines;
  Position get currentPosition => _currentPosition;
  Directions get directions => _directions;
  Set<Marker> get markers => _markers;
  List<Order> get orderQueue => _orderQueue;
  String get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;

  Future loadOrders() async {
    await getCurrentPosition();
    _isLoading = true;
    notifyListeners();
    return repository.loadOrders().then((loadedOrders) {
      _orderQueue.addAll(loadedOrders);
      _createMarkers();
      _isLoading = false;
      notifyListeners();
    }).catchError((dynamic error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error caught: $error');
    });
  }

  Future<void> createOfficeMarkers() async {
    final offices = await locations.getOffices();
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(10, 10)),
        'assets/images/green_salad_windows.png');

    _markers.clear();
    for (final office in offices.offices!) {
      final marker = Marker(
        markerId: MarkerId(office.name!),
        position: LatLng(office.lat!, office.lng!),
        // icon: customIcon,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: office.name,
          snippet: office.address,
        ),
      );
      _markers.add(marker);
      notifyListeners();
    }
  }

  void _createMarkers() {
    _markers.addAll(
      _orderQueue.where((order) => !order.complete).map(
        (order) {
          return Marker(
            markerId: MarkerId(order.id),
            position: LatLng(order.lat, order.lng),
            infoWindow: InfoWindow(
              title: '${_orderQueue.indexOf(order) + 1}. ${order.customer}',
              snippet: order.street,
            ),
          );
        },
      ),
    );
    notifyListeners();
    createRoute();
  }

  void removeMarker(String id) {
    _markers.removeWhere((element) => element.markerId == MarkerId(id));
    // notifyListeners();
  }

  void removeCompletedMarkers(MarkerId markerId) {
    // _markers.clear();
    notifyListeners();
  }

  void clearCompleted() {
    _orderQueue.removeWhere((order) => order.complete);
    notifyListeners();
    _uploadItems();
  }

// showMarkerInfoWindow

  void updateOrder(Order order) {
    final oldOrder = _orderQueue.firstWhere((it) => it.id == order.id);
    final replaceIndex = _orderQueue.indexOf(oldOrder);
    _orderQueue.replaceRange(replaceIndex, replaceIndex + 1, [order]);
    removeMarker(order.id);
    // getCurrentPosition();

    // notifyListeners();

    _uploadItems();
  }

  void _uploadItems() {
    // repository.saveOrders(_orderQueue.map((it) => it.toEntity()).toList());
  }

  Future<void> getCurrentPosition() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> addOrderMarkers(OrderListModel model) async {
    // await getCurrentPosition();

    // TODO(master): is there a better way then to call getDirections from here?
    // await getDirections();
  }

  Future<void> createRoute() async {
    // if (_markers.isNotEmpty) {
    //   _markers.clear();
    // }
    // _markers.addAll(markers);

    hasActiveOrders
        ? await getDirections(currentOrder.lat, currentOrder.lng)
        : await getDirections(storeLatitudeHamburg, storeLongitudeHamburg);
  }

  Future<void> getDirections(
      double destinationLatitude, double destinationLongitude) async {
    _directions = await DirectionsRepository().getDirections(
      origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      destination: LatLng(destinationLatitude, destinationLongitude),
    );
    notifyListeners();
    createPolylines();
  }

  void createPolylines() {
    if (_polylines.isNotEmpty) {
      _polylines.clear();
    }

    const id = PolylineId('poly');
    final polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      width: 6,
      points: _directions.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList(),
    );
    _polylines[id] = polyline;
  }

  Order orderById(String id) {
    return _orderQueue.firstWhere((it) => it.id == id);
  }

  Order get currentOrder {
    print(' currentOrder');
    // print(StackTracye.current);
    return orderQueue.firstWhere((Order order) => !order.complete);
  }

  int get numCompleted =>
      orderQueue.where((Order order) => order.complete).toList().length;

  bool get hasCompleted => numCompleted > 0;

  int get numUncompleted =>
      orderQueue.where((Order order) => !order.complete).toList().length;

  bool get hasActiveOrders => numUncompleted > 0;

  String get routeDuration => directions.totalDistance;

  String get routeDistance => directions.totalDistance;
}
