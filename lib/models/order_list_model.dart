import 'package:cyclopath/utils/json_parsing.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'order.dart';

class OrderListModel extends ChangeNotifier {
  OrderListModel({
    required this.repository,
    List<Order>? orderQueue,
  }) : _orderQueue = orderQueue ?? [];

  final List<Order> _orderQueue;
  final OrderRepository repository;
  final Set<Marker> _markers = {};

  // OrderRepository repository = OrderRepository();
  final String _selectedOrder = '';
  bool _isLoading = false;

  Set<Marker> get markers => _markers;
  List<Order> get orderQueue => _orderQueue;
  String get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;

  Future loadOrders() {
    _isLoading = true;
    notifyListeners();
    return repository.loadOrders().then((loadedOrders) {
      _orderQueue.addAll(loadedOrders);
      createMarkers();
      _isLoading = false;
      notifyListeners();
    }).catchError((dynamic error) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error caught: $error');
    });
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
    notifyListeners();
    _uploadItems();
  }

  void _uploadItems() {
    // repository.saveOrders(_orderQueue.map((it) => it.toEntity()).toList());
  }

  void createMarkers() {
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
  }

  void removeMarker(String id) {
    _markers.removeWhere((element) => element.markerId == MarkerId(id));
    notifyListeners();
  }

  void removeCompletedMarkers(MarkerId markerId) {
    _markers.clear();
    notifyListeners();
  }

  Order orderById(String id) {
    return _orderQueue.firstWhere((it) => it.id == id);
  }

  Order get currentOrder =>
      orderQueue.firstWhere((Order order) => !order.complete);

  int get numCompleted =>
      orderQueue.where((Order order) => order.complete).toList().length;

  bool get hasCompleted => numCompleted > 0;

  int get numUncompleted =>
      orderQueue.where((Order order) => !order.complete).toList().length;

  bool get hasActiveOrders => numUncompleted > 0;
}
