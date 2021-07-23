import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  Order({
    required this.ordernumber,
    required this.customer,
    required this.street,
    required this.city,
    required this.postal,
    required this.lat,
    required this.lng,
    required this.phone,
    this.email = '',
    this.note = '',
    this.tip = 0,
    bool? complete,
    String? id,
    DateTime? selectedDeliveryTime,
    this.queueNumber,
  })  : complete = complete ?? false,
        id = id ?? const Uuid().v4(),
        selectedDeliveryTime = selectedDeliveryTime ??
            DateTime.now().add(
              const Duration(minutes: 5 + 2 * 3),
            );

  final String id;
  final String ordernumber;
  final String customer;
  final String street;
  final String city;
  final double lat;
  final double lng;
  final String postal;
  final String phone;
  final String email;
  final String note;
  final double tip;
  // @JsonKey(defaultValue: false)
  final bool complete;
  final DateTime selectedDeliveryTime;
  final double? queueNumber;

  // ignore: sort_constructors_first
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? newid,
    String? neworderNum,
    String? newcustomer,
    String? newstreet,
    String? newcity,
    String? newpostal,
    double? newlat,
    double? newlng,
    String? newphone,
    String? newemail,
    double? newtip,
    String? newnote,
    bool? newcomplete,
    DateTime? newselectedDeliveryTime,
    double? newqueueNumber,
  }) {
    return Order(
      ordernumber: neworderNum ?? ordernumber,
      customer: newcustomer ?? customer,
      street: newstreet ?? street,
      city: newcity ?? city,
      postal: newpostal ?? postal,
      lat: newlat ?? lat,
      lng: newlng ?? lng,
      phone: newphone ?? phone,
      id: newid ?? id,
      email: newemail ?? email,
      tip: newtip ?? tip,
      note: newnote ?? note,
      complete: newcomplete ?? complete,
      queueNumber: newqueueNumber ?? queueNumber,
    );
  }
}
