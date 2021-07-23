import 'package:cyclopath/custom_widgets/adaptive_navi.dart';
import 'package:cyclopath/utils/json_parsing.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cyclopath/models/storeLocations.dart' as locations;

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
  final Map<PolylineId, Polyline> _polylines = {};
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  bool _isLoading = false;

  late Order _currentOrder;
  late locations.Office _office;
  late Directions _directions;
  late Position _currentPosition;
  late BitmapDescriptor customIcon;

  Map<PolylineId, Polyline> get polylines => _polylines;
  Position get currentPosition => _currentPosition;
  Directions get directions => _directions;
  locations.Office get office => _office;
  Map<MarkerId, Marker> get markers => _markers;
  List<Order> get orderQueue => _orderQueue;
  Order get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;

  Future loadOrders() async {
    await getCurrentPosition();
    _isLoading = true;
    notifyListeners();
    return repository.loadOrders().then((loadedOrders) {
      _orderQueue.addAll(loadedOrders);
      setCurrentOrder();
      _createMarkers();
      createRoute();
      // _createPolylines();
      _isLoading = false;
      notifyListeners();
    }).catchError((dynamic error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error caught: $error');
    });
  }

  Future<void> createOfficeMarkers() async {
    _office = await locations.getOffices(storeIdHamburg);
    customIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(10, 10)),
        'assets/images/green_salad_windows.png');

    _markers.clear();

    final marker = Marker(
      markerId: MarkerId(_office.name!),
      position: LatLng(_office.lat!, _office.lng!),
      // icon: customIcon,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: _office.name,
        snippet: _office.address,
      ),
    );
    _markers[MarkerId(_office.id!)] = marker;
    notifyListeners();
  }

  void _createMarkers() {
    if (_markers.isNotEmpty) {
      _markers.clear();
    }
    final uncompleteOrders =
        _orderQueue.where((order) => !order.complete).toList();

    for (final order in uncompleteOrders) {
      final marker = Marker(
        markerId: MarkerId(order.id),
        position: LatLng(order.lat, order.lng),
        // infoWindow: InfoWindow(
        //   // title: "heloooo",
        //   title: '${_orderQueue.indexOf(order) + 1}. ${order.customer}',
        //   snippet: order.street,
        // ),
        onTap: () {
          _currentOrder = order;
          createRoute();
          notifyListeners();
        },
      );
      _markers[marker.markerId] = marker;
    }
    // notifyListeners();
  }

  void _changeMarkerInfo() {
    print('_changeMarkerInfo');
    final selectedMarkerId = destinationMarkerId;

    if (_markers.containsKey(selectedMarkerId)) {
      final marker = _markers[selectedMarkerId]!;
      // const icon = Icons.pedal_bike;
      _markers[selectedMarkerId] = marker.copyWith(
        infoWindowParam: InfoWindow(
          title:
              '${_directions.totalDurationText} • ${_directions.totalDistance} ',
        ),
      );
    }
    notifyListeners();
  }

  void removeMarker(String id) {
    final selectedMarkerId = MarkerId(id);
    if (_markers.containsKey(selectedMarkerId)) {
      _markers.remove(selectedMarkerId);
    }
  }

  void clearCompleted() {
    _orderQueue.removeWhere((order) => order.complete);
    notifyListeners();
    _uploadItems();
  }

  void updateOrder(Order order) {
    final oldOrder = _orderQueue.firstWhere((it) => it.id == order.id);
    final replaceIndex = _orderQueue.indexOf(oldOrder);
    _orderQueue.replaceRange(replaceIndex, replaceIndex + 1, [order]);
    removeMarker(order.id);
    setCurrentOrder();
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

  Future<void> createRoute() async {
    _directions = await DirectionsRepository().getDirections(
      origin: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      destination: LatLng(destinationLatitude, destinationLongitude),
    );
    _createPolylines();
    notifyListeners();
    // _createMarkers();
    // _changeMarkerInfo();
  }

  void _createPolylines() {
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
    _changeMarkerInfo();
    // notifyListeners();
  }

  Order orderById(String id) {
    return _orderQueue.firstWhere((it) => it.id == id);
  }

  void setCurrentOrder() {
    final contain = orderQueue.where((Order order) => !order.complete);
    if (contain.isNotEmpty) {
      _currentOrder = orderQueue.firstWhere((Order order) => !order.complete);
      notifyListeners();
    }
  }

  // Duration routeDuration() {
  //   var hours = 0;
  //   var minutes = 0;
  //   int micros;
  //   final parts =
  //       directions.totalDurationText.replaceAll(RegExp(r'[^0-9]'), '').split(':');
  //   if (parts.length > 2) {
  //     hours = int.parse(parts[parts.length - 3]);
  //   }
  //   if (parts.length > 1) {
  //     minutes = int.parse(parts[parts.length - 2]);
  //   }
  //   micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  //   return Duration(hours: hours, minutes: minutes, microseconds: micros);
  // }

  int get numCompleted =>
      orderQueue.where((Order order) => order.complete).toList().length;

  bool get hasCompleted => numCompleted > 0;

  int get numUncompleted =>
      orderQueue.where((Order order) => !order.complete).toList().length;

  bool get hasActiveOrders => numUncompleted > 0;

  double get destinationLatitude =>
      hasActiveOrders ? _currentOrder.lat : storeLatitudeHamburg;

  double get destinationLongitude =>
      hasActiveOrders ? _currentOrder.lng : storeLongitudeHamburg;

  MarkerId get destinationMarkerId =>
      hasActiveOrders ? MarkerId(_currentOrder.id) : MarkerId(_office.id!);
}
