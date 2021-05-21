import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  Order({
    required this.orderNum,
    required this.customer,
    required this.street,
    required this.city,
    required this.postal,
    required this.phone,
    this.email = '',
    this.note = '',
    this.tip = 0,
    this.complete = false,
    String? id,
    DateTime? selectedDeliveryTime,
  })  : id = id ?? const Uuid().v4(),
        selectedDeliveryTime = selectedDeliveryTime ??
            DateTime.now().add(
              const Duration(minutes: 5 + 2 * 3),
            );

  final String id;
  final String orderNum;
  final String customer;
  final String street;
  final String city;
  final String postal;
  final String phone;
  final String email;
  final String note;
  final double tip;
  final bool complete;
  final DateTime selectedDeliveryTime;

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
    String? newphone,
    String? newemail,
    double? newtip,
    String? newnote,
    bool? newcomplete,
    DateTime? newselectedDeliveryTime,
  }) {
    return Order(
        orderNum: neworderNum ?? orderNum,
        customer: newcustomer ?? customer,
        street: newstreet ?? street,
        city: newcity ?? city,
        postal: newpostal ?? postal,
        phone: newphone ?? phone,
        id: newid ?? id,
        email: newemail ?? email,
        tip: newtip ?? tip,
        note: newnote ?? note,
        complete: newcomplete ?? complete);
  }
}
